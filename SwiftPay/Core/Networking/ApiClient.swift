import Foundation
import OSLog

enum APIClientError: Error {
    static let genericUserMessage = "Something went wrong"

    case invalidURL
    case invalidResponse
    case httpStatus(Int, message: String)
    case network(Error)
    case decoding(Error)
    case encoding(Error)
    case authenticationStorage(Error)

    var userMessage: String {
        switch self {
        case let .httpStatus(_, message):
            return message
        case .invalidURL, .invalidResponse, .network(_), .decoding(_), .encoding,
            .authenticationStorage(_):
            return Self.genericUserMessage
        }
    }
}

extension Error {
    var userMessage: String {
        if let apiError = self as? APIClientError {
            return apiError.userMessage
        }
        return APIClientError.genericUserMessage
    }
}

private struct APIErrorResponse: Decodable {
    let error: APIErrorBody
}

private struct APIErrorBody: Decodable {
    let message: String
}

final class APIClient {
    private let baseUrl: URL
    private let session: URLSession
    private let authTokenStore: AuthTokenStore
    private let sessionManager: SessionManager
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "SwiftPay",
        category: "APIClient"
    )

    init(
        baseUrl: URL,
        session: URLSession,
        authTokenStore: AuthTokenStore,
        sessionManager: SessionManager
    ) {
        self.baseUrl = baseUrl
        self.session = session
        self.authTokenStore = authTokenStore
        self.sessionManager = sessionManager
    }

    func get<Response: Decodable>(
        _ endpoint: String,
        queryItems: [URLQueryItem] = [],
        as responseType: Response.Type
    ) async throws -> Response {
        var request = try makeRequest(
            endpoint: endpoint,
            method: "GET",
            queryItems: queryItems
        )
        try await addAuthorizationHeader(to: &request, required: true)
        return try await send(request, as: responseType)
    }

    func post<Body: Encodable, Response: Decodable>(
        _ endpoint: String,
        body: Body,
        idempotencyKey: String,
        requiresAuthentication: Bool = true,
        as responseType: Response.Type
    ) async throws -> Response {
        var request = try makeRequest(endpoint: endpoint, method: "POST")
        try await addAuthorizationHeader(
            to: &request,
            required: requiresAuthentication
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(idempotencyKey, forHTTPHeaderField: "Idempotency-Key")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            let apiError = APIClientError.encoding(error)
            log(apiError, for: request)
            throw apiError
        }

        return try await send(request, as: responseType)
    }

    private func addAuthorizationHeader(
        to request: inout URLRequest,
        required: Bool
    ) async throws {
        guard required else { return }

        do {
            guard let token = try await authTokenStore.fetchToken() else { return }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } catch {
            let apiError = APIClientError.authenticationStorage(error)
            log(apiError, for: request)
            throw apiError
        }
    }

    private func makeRequest(
        endpoint: String,
        method: String,
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseUrl,
            resolvingAgainstBaseURL: false
        ) else {
            logger.error("Could not create URL components for endpoint \(endpoint, privacy: .private)")
            throw APIClientError.invalidURL
        }

        let basePath = components.path.trimmingCharacters(
            in: CharacterSet(charactersIn: "/")
        )
        let endpointPath = endpoint.trimmingCharacters(
            in: CharacterSet(charactersIn: "/")
        )
        let path = [basePath, endpointPath]
            .filter { !$0.isEmpty }
            .joined(separator: "/")

        components.path = "/" + path
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            logger.error("Could not create a URL for endpoint \(endpoint, privacy: .private)")
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15
        return request
    }

    private func send<Response: Decodable>(
        _ request: URLRequest,
        as responseType: Response.Type
    ) async throws -> Response {
        let (data, response) = try await perform(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            log(APIClientError.invalidResponse, for: request)
            throw APIClientError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                let cleanupFailures = await sessionManager.handleUnauthorized()
                if !cleanupFailures.isEmpty {
                    logger.error(
                        "Unauthorized session cleanup failed: \(cleanupFailures.joined(separator: "; "), privacy: .private)"
                    )
                }
            }

            let message = decodeBackendErrorMessage(from: data, for: request)
                ?? APIClientError.genericUserMessage
            let error = APIClientError.httpStatus(
                httpResponse.statusCode,
                message: message
            )
            log(error, for: request)
            throw error
        }

        do {
            return try Self.makeDecoder().decode(responseType, from: data)
        } catch {
            let apiError = APIClientError.decoding(error)
            log(apiError, for: request)
            throw apiError
        }
    }

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch let error as CancellationError {
            throw error
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            let apiError = APIClientError.network(error)
            log(apiError, for: request)
            throw apiError
        }
    }

    private func decodeBackendErrorMessage(
        from data: Data,
        for request: URLRequest
    ) -> String? {
        do {
            let response = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            let message = response.error.message.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            return message.isEmpty ? nil : message
        } catch {
            log(error, for: request, context: "Could not decode backend error response")
            return nil
        }
    }

    private func log(
        _ error: Error,
        for request: URLRequest,
        context: String = "Request failed"
    ) {
        let method = request.httpMethod ?? "UNKNOWN"
        let path = request.url?.path ?? "<unknown path>"
        logger.error(
            "\(context, privacy: .public): \(method, privacy: .public) \(path, privacy: .private): \(String(reflecting: error), privacy: .private)"
        )
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let fractionalFormatter = ISO8601DateFormatter()
            fractionalFormatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds,
            ]

            if let date = fractionalFormatter.date(from: dateString) {
                return date
            }

            let standardFormatter = ISO8601DateFormatter()
            standardFormatter.formatOptions = [.withInternetDateTime]

            if let date = standardFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected an ISO 8601 date string."
            )
        }

        return decoder
    }
}
