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
        guard !isRefreshing, !isLoadingNextPage else { return }

        isRefreshing = true
        errorMessage = nil
        defer { isRefreshing = false }

        do {
            let cachedTransactions =
                try await transactionRepository.fetchCachedTransactions()
            pagination = try await transactionRepository.fetchCachedPagination()
            if !cachedTransactions.isEmpty {
                transactions = cachedTransactions
            }
        } catch {
            errorMessage = error.userMessage
        }

        do {
            let response = try await transactionRepository.fetchTransactions(
                limit: 10
            )
            let refreshedIDs = Set(response.transactions.map(\.id))
            let olderCachedTransactions = transactions.filter {
                !refreshedIDs.contains($0.id)
            }
            errorMessage = nil
            transactions = response.transactions + olderCachedTransactions
            if pagination == nil {
                pagination = response.pagination
            }
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.userMessage
        }
    }

    func fetchNextPage() async {
        guard
            !isLoadingNextPage,
            !isRefreshing,
            let currentPagination = pagination,
            currentPagination.hasMore,
            let cursor = currentPagination.nextCursor
        else {
            return
        }

        isLoadingNextPage = true
        errorMessage = nil
        defer { isLoadingNextPage = false }
        do {
            let response =
                try await transactionRepository.fetchTransactions(
                    after: cursor,
                    limit: currentPagination.limit
                )
            let existingIDs = Set(transactions.map(\.id))
            transactions.append(
                contentsOf: response.transactions.filter {
                    !existingIDs.contains($0.id)
                }
            )
            self.pagination = response.pagination
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.userMessage
        }
    }

    func insertNewTransaction(_ transaction: Transaction) async {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            return
        }

        transactions.insert(transaction, at: 0)

        do {
            try await transactionRepository.saveTransaction(transaction)
        } catch {
            errorMessage = error.userMessage
        }
    }
}
