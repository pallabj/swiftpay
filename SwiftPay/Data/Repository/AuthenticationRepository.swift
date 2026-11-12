import Foundation

private struct DemoLoginRequest: Encodable {}

private struct DemoLoginResponse: Decodable {
    let token: String
}

struct AuthenticationRepository {
    private let apiClient: APIClient
    private let authTokenStore: AuthTokenStore

    init(apiClient: APIClient, authTokenStore: AuthTokenStore) {
        self.apiClient = apiClient
        self.authTokenStore = authTokenStore
    }

    func login() async throws {
        let response = try await apiClient.post(
            "auth/login",
            body: DemoLoginRequest(),
            idempotencyKey: UUID().uuidString,
            requiresAuthentication: false,
            as: DemoLoginResponse.self
        )
        try await authTokenStore.saveToken(response.token)
    }
}
