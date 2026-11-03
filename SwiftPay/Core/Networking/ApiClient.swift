import Foundation

enum APIClientError: Error {
    case invalidURL
    case invalidResponse
    case httpStatus(Int, message: String?)
    case decoding(Error)
    case encoding(Error)
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

    init(baseUrl: URL, session: URLSession) {
        self.baseUrl = baseUrl
        self.session = session
    }

    func get<Response: Decodable>(
        _ endpoint: String,
        queryItems: [URLQueryItem] = [],
        as responseType: Response.Type
    ) async throws -> Response {
        guard
            var components = URLComponents(
                url: baseUrl,
                resolvingAgainstBaseURL: false
            )
        else {
            throw APIClientError.invalidURL
        }

        components.path =
            "/"
            + endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(
                APIErrorResponse.self,
                from: data
            )

            throw APIClientError.httpStatus(
                httpResponse.statusCode,
                message: errorResponse?.error.message
            )
        }

        do {
            return try Self.makeDecoder().decode(responseType, from: data)
        } catch {
            throw APIClientError.decoding(error)
        }
    }

    func post<Body: Encodable, Response: Decodable>(
        _ endpoint: String,
        body: Body,
        idempotencyKey: String,
        as responseType: Response.Type
    ) async throws -> Response {
        guard
            var components = URLComponents(
                url: baseUrl,
                resolvingAgainstBaseURL: false
            )
        else {
            throw APIClientError.invalidURL
        }

        components.path =
            "/"
            + endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        guard let url = components.url else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(idempotencyKey, forHTTPHeaderField: "Idempotency-Key")
        request.timeoutInterval = 15

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIClientError.encoding(error)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(
                APIErrorResponse.self,
                from: data
            )

            throw APIClientError.httpStatus(
                httpResponse.statusCode,
                message: errorResponse?.error.message
            )
        }

        do {
            return try Self.makeDecoder().decode(responseType, from: data)
        } catch {
            throw APIClientError.decoding(error)
        }
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
