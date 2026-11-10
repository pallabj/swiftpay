import Combine
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var pagination: TransactionPagination?
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var errorMessage: String?

    private let transactionRepository: TransactionRepository

    init(transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }

    func refreshTransactions() async {
        print("refreshTransactions isLoadingNextPage: ", isLoadingNextPage)
        guard !isRefreshing, !isLoadingNextPage else { return }

        isRefreshing = true
        errorMessage = nil
        defer { isRefreshing = false }

        do {
            let response = try await transactionRepository.fetchTransactions(
                offset: 0,
                limit: 10
            )
            transactions = response.transactions
            pagination = response.pagination
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.userMessage
        }
    }

    func fetchNextPage() async {
        print("fetchNextPage isLoadingNextPage: ", isLoadingNextPage)
        guard
            !isLoadingNextPage,
            !isRefreshing,
            pagination?.hasMore != false
        else {
            return
        }

        isLoadingNextPage = true
        errorMessage = nil
        defer { isLoadingNextPage = false }
        do {
            let response =
                try await transactionRepository.fetchTransactions(
                    offset: pagination?.nextOffset ?? 0,
                    limit: 10
                )
            let existingIDs = Set(transactions.map(\.id))
            transactions.append(
                contentsOf: response.transactions.filter {
                    !existingIDs.contains($0.id)
                }
            )
            pagination = response.pagination
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.userMessage
        }
    }

    func insertNewTransaction(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            return
        }

        transactions.insert(transaction, at: 0)

        guard let pagination else { return }

        self.pagination = TransactionPagination(
            limit: pagination.limit,
            offset: pagination.offset,
            total: pagination.total + 1,
            hasMore: pagination.hasMore,
            nextOffset: pagination.hasMore ? transactions.count : nil
        )
    }
}
