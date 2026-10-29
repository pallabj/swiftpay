import Foundation

struct WalletRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchWallet() async throws -> Wallet {
        try await apiClient.get("wallet", as: Wallet.self)
    }
}
