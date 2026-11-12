import Foundation
import SwiftData

@ModelActor
actor CachedTransactionStore {

    func fetchTransactions() throws -> [Transaction] {
        let descriptor = FetchDescriptor<CachedTransaction>(
            sortBy: [
                SortDescriptor(\CachedTransaction.createdAt, order: .reverse),
                SortDescriptor(\CachedTransaction.id, order: .reverse),
            ]
        )
        let cachedTransactions = try modelContext.fetch(descriptor)
        return cachedTransactions.map { $0.toTransaction() }
    }

    func saveTransactions(_ transactions: [Transaction]) throws {
        try upsertTransactions(transactions)
        try modelContext.save()
    }

    private func upsertTransactions(_ transactions: [Transaction]) throws {
        for transaction in transactions {
            let transactionID = transaction.id
            let descriptor = FetchDescriptor<CachedTransaction>(
                predicate: #Predicate { cachedTransaction in
                    cachedTransaction.id == transactionID
                }
            )

            if let cachedTransaction = try modelContext.fetch(descriptor).first
            {
                cachedTransaction.type = transaction.type
                cachedTransaction.amount = transaction.amount
                cachedTransaction.currency = transaction.currency
                cachedTransaction.recipientId = transaction.recipientId
                cachedTransaction.recipientName = transaction.recipientName
                cachedTransaction.recipientPhone = transaction.recipientPhone
                cachedTransaction.transactionDescription =
                    transaction.description
                cachedTransaction.status = transaction.status
                cachedTransaction.createdAt = transaction.createdAt
            } else {
                modelContext.insert(CachedTransaction(transaction: transaction))
            }
        }
    }

    func fetchPagination(id paginationID: String) throws -> TransactionPagination? {
        var descriptor = FetchDescriptor<CachedTransactionPagination>(
            predicate: #Predicate { $0.id == paginationID }
        )
        descriptor.fetchLimit = 1

        let cachedPagination = try modelContext.fetch(descriptor).first
        return cachedPagination?.toPagination()
    }

    func savePage(
        transactions: [Transaction],
        pagination: TransactionPagination,
        checkpointID: String
    ) throws {
        try upsertTransactions(transactions)

        let descriptor = FetchDescriptor<CachedTransactionPagination>(
            predicate: #Predicate { $0.id == checkpointID }
        )

        if let cachedPagination = try modelContext.fetch(descriptor).first {
            cachedPagination.limit = pagination.limit
            cachedPagination.hasMore = pagination.hasMore
            cachedPagination.nextCursor = pagination.nextCursor
        } else {
            modelContext.insert(
                CachedTransactionPagination(
                    id: checkpointID,
                    limit: pagination.limit,
                    hasMore: pagination.hasMore,
                    nextCursor: pagination.nextCursor
                )
            )
        }

        try modelContext.save()
    }

    func clear() throws {
        let transactions = try modelContext.fetch(
            FetchDescriptor<CachedTransaction>()
        )
        transactions.forEach(modelContext.delete)

        let pagination = try modelContext.fetch(
            FetchDescriptor<CachedTransactionPagination>()
        )
        pagination.forEach(modelContext.delete)

        try modelContext.save()
    }
}
