import Foundation

enum APIClientError: Error {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
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
            throw APIClientError.httpStatus(httpResponse.statusCode)
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
