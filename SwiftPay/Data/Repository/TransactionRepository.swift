import Foundation

struct TransactionRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchTransactions(offset: Int = 0, limit: Int = 10) async throws
        -> TransactionPage
    {
        try await apiClient.get(
            "transactions",
            queryItems: [
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit)),
            ],
            as: TransactionPage.self
        )
    }
}
