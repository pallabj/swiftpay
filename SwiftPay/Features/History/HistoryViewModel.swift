import Combine
import Foundation

enum TransactionTypeFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case credits
    case debits

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .credits: "Credit"
        case .debits: "Debits"
        }
    }

    var apiValue: String? {
        switch self {
        case .all: nil
        case .credits: "credit"
        case .debits: "debit"
        }
    }
}

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var pagination: TransactionPagination?
    @Published private(set) var isLoadingNextPage = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var searchText = ""
    @Published private(set) var selectedFilter: TransactionTypeFilter = .all

    private let transactionRepository: TransactionRepository
    private var queryRefreshTask: Task<Void, Never>?

    init(transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }

    var filteredTransactions: [Transaction] {
        let typeFilteredTransactions = transactions.filter { transaction in
            switch selectedFilter {
            case .all:
                true
            case .credits:
                transaction.type == "credit"
            case .debits:
                transaction.type == "debit"
            }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard !query.isEmpty else { return typeFilteredTransactions }

        let queryDigits = query.filter(\.isNumber)
        let queryAmount = Decimal(
            string: query,
            locale: Locale(identifier: "en_US_POSIX")
        )

        return typeFilteredTransactions.filter { transaction in
            let matchesName = transaction.recipientName?
                .localizedCaseInsensitiveContains(query) == true
            let phoneDigits = (transaction.recipientPhone ?? "")
                .filter(\.isNumber)
            let matchesPhone = !queryDigits.isEmpty
                && phoneDigits.range(of: queryDigits) != nil
            let amountText = NSDecimalNumber(decimal: transaction.amount)
                .stringValue
            let matchesAmount = amountText.contains(query)
                || queryAmount == transaction.amount

            return matchesName || matchesPhone || matchesAmount
        }
    }

    var recentTransactions: [Transaction] {
        Array(transactions.prefix(5))
    }

    private var checkpointID: String {
        let normalizedSearch = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        guard selectedFilter != .all || !normalizedSearch.isEmpty else {
            return "transaction-history"
        }

        return "transaction-history|\(selectedFilter.apiValue ?? "all")|\(normalizedSearch)"
    }

    func updateSearchText(_ value: String) {
        let newValue = String(value.prefix(100))
        guard newValue != searchText else { return }
        searchText = newValue
        scheduleQueryRefresh(debounce: true)
    }

    func selectFilter(_ filter: TransactionTypeFilter) {
        guard filter != selectedFilter else { return }
        selectedFilter = filter
        scheduleQueryRefresh(debounce: false)
    }

    private func scheduleQueryRefresh(debounce: Bool) {
        pagination = nil
        queryRefreshTask?.cancel()
        queryRefreshTask = Task { [weak self] in
            guard let self else { return }

            if debounce {
                do {
                    try await Task.sleep(for: .milliseconds(300))
                } catch {
                    return
                }
            }

            while self.isRefreshing || self.isLoadingNextPage {
                do {
                    try await Task.sleep(for: .milliseconds(50))
                } catch {
                    return
                }
            }

            await self.refreshTransactions()
        }
    }

    func refreshTransactions() async {
        guard !isRefreshing, !isLoadingNextPage else { return }

        let requestSearch = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let requestType = selectedFilter.apiValue
        let requestCheckpointID = checkpointID

        isRefreshing = true
        errorMessage = nil
        defer { isRefreshing = false }

        do {
            let cachedTransactions =
                try await transactionRepository.fetchCachedTransactions()
            pagination = try await transactionRepository.fetchCachedPagination(
                id: requestCheckpointID
            )
            if !cachedTransactions.isEmpty {
                transactions = cachedTransactions
            }
        } catch {
            errorMessage = error.userMessage
        }

        do {
            let response = try await transactionRepository.fetchTransactions(
                limit: 10,
                search: requestSearch,
                type: requestType,
                checkpointID: requestCheckpointID
            )
            mergeTransactions(response.transactions)
            errorMessage = nil
            pagination = response.pagination
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

        let requestSearch = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let requestType = selectedFilter.apiValue
        let requestCheckpointID = checkpointID

        isLoadingNextPage = true
        errorMessage = nil
        defer { isLoadingNextPage = false }

        do {
            let response = try await transactionRepository.fetchTransactions(
                after: cursor,
                limit: currentPagination.limit,
                search: requestSearch,
                type: requestType,
                checkpointID: requestCheckpointID
            )
            mergeTransactions(response.transactions)
            pagination = response.pagination
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

        mergeTransactions([transaction])

        do {
            try await transactionRepository.saveTransaction(transaction)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func clearSessionData() {
        queryRefreshTask?.cancel()
        queryRefreshTask = nil
        transactions = []
        pagination = nil
        isLoadingNextPage = false
        isRefreshing = false
        errorMessage = nil
        searchText = ""
        selectedFilter = .all
    }

    private func mergeTransactions(_ updates: [Transaction]) {
        var transactionsByID: [String: Transaction] = [:]
        for transaction in transactions + updates {
            transactionsByID[transaction.id] = transaction
        }

        transactions = transactionsByID.values.sorted { first, second in
            if first.createdAt != second.createdAt {
                return first.createdAt > second.createdAt
            }
            return first.id > second.id
        }
    }
}
