import Foundation

private struct DemoLoginRequest: Encodable {}

private struct DemoLoginResponse: Decodable {
    let token: String
}

struct AuthenticationRepository {
    private let apiClient: APIClient
    private let sessionTokenStore: SessionTokenStore

    init(apiClient: APIClient, sessionTokenStore: SessionTokenStore) {
        self.apiClient = apiClient
        self.sessionTokenStore = sessionTokenStore
    }

    func login() async throws {
        let response = try await apiClient.post(
            "auth/login",
            body: DemoLoginRequest(),
            idempotencyKey: UUID().uuidString,
            requiresAuthentication: false,
            as: DemoLoginResponse.self
        )
        await sessionTokenStore.saveToken(response.token)
    }
}
