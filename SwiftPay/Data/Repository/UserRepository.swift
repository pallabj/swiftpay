import Foundation

struct UserRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getUser() async throws -> User {
        return try await apiClient.get("user", as: User.self)
    }
}
