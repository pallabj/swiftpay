import Combine
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var pagination: TransactionPagination?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let transactionRepository: TransactionRepository

    init(transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }

    func fetchNextPage() async {
        guard !isLoading, pagination?.hasMore != false else { return }
        let offset = pagination?.nextOffset ?? 0

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response =
                try await transactionRepository.fetchTransactions(
                    offset: offset,
                    limit: 10
                )
            transactions.append(contentsOf: response.transactions)
            pagination = response.pagination
        } catch {
            errorMessage = "Failed loading transactions, please try again!"
        }
    }
}
