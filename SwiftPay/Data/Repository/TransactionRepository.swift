import Foundation

struct TransactionRepository {
    private let apiClient: APIClient
    private let cachedTransactionStore: CachedTransactionStore

    init(apiClient: APIClient, cachedTransactionStore: CachedTransactionStore) {
        self.apiClient = apiClient
        self.cachedTransactionStore = cachedTransactionStore
    }

    func fetchTransactions(after cursor: String? = nil, limit: Int = 10) async throws
        -> TransactionPage
    {
        var queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        if let cursor {
            queryItems.append(URLQueryItem(name: "after", value: cursor))
        }

        let page = try await apiClient.get(
            "transactions",
            queryItems: queryItems,
            as: TransactionPage.self
        )

        try await cachedTransactionStore.saveTransactions(page.transactions)
        return page
    }

    func fetchCachedTransactions() async throws -> [Transaction] {
        try await cachedTransactionStore.fetchTransactions()
    }
    
    func saveTransaction(_ transaction: Transaction) async throws {
        try await cachedTransactionStore.saveTransactions([transaction])
    }
}
