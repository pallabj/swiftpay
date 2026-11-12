import Foundation

struct TransactionRepository {
    private let apiClient: APIClient
    private let cachedTransactionStore: CachedTransactionStore

    init(apiClient: APIClient, cachedTransactionStore: CachedTransactionStore) {
        self.apiClient = apiClient
        self.cachedTransactionStore = cachedTransactionStore
    }

    func fetchTransactions(
        after cursor: String? = nil,
        limit: Int = 10,
        search: String? = nil,
        type: String? = nil,
        checkpointID: String = "transaction-history"
    )
        async throws
        -> TransactionPage
    {
        var queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        if let cursor {
            queryItems.append(URLQueryItem(name: "after", value: cursor))
        }
        if let search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        if let type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }

        let page = try await apiClient.get(
            "transactions",
            queryItems: queryItems,
            as: TransactionPage.self
        )

        try await cachedTransactionStore.savePage(
            transactions: page.transactions,
            pagination: page.pagination,
            checkpointID: checkpointID
        )
        return page
    }

    func fetchCachedTransactions() async throws -> [Transaction] {
        try await cachedTransactionStore.fetchTransactions()
    }

    func saveTransaction(_ transaction: Transaction) async throws {
        try await cachedTransactionStore.saveTransactions([transaction])
    }

    func fetchCachedPagination(id: String) async throws -> TransactionPagination? {
        try await cachedTransactionStore.fetchPagination(id: id)
    }
}
