import Foundation

struct WalletRepository {
    private let apiClient: APIClient
    private let cachedWalletStore: CachedWalletStore

    init(apiClient: APIClient, cachedWalletStore: CachedWalletStore) {
        self.apiClient = apiClient
        self.cachedWalletStore = cachedWalletStore
    }

    func fetchWallet() async throws -> Wallet {
        let wallet = try await apiClient.get("wallet", as: Wallet.self)
        try await cachedWalletStore.saveWallet(wallet)
        return wallet
    }

    func fetchCachedWallet() async throws -> Wallet? {
        try await cachedWalletStore.fetchWallet()
    }
    
    func saveCachedWallet(_ wallet: Wallet) async throws {
        try await cachedWalletStore.saveWallet(wallet)
    }
}
