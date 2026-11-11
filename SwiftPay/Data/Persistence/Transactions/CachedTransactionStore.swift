import Foundation
import SwiftData

@ModelActor
actor CachedTransactionStore {

    func fetchTransactions() throws -> [Transaction] {
        let descriptor = FetchDescriptor<CachedTransaction>(
            sortBy: [
                SortDescriptor(\CachedTransaction.createdAt, order: .reverse),
                SortDescriptor(\CachedTransaction.id, order: .reverse)
            ]
        )
        let cachedTransactions = try modelContext.fetch(descriptor)
        return cachedTransactions.map { $0.toTransaction() }
    }

    func saveTransactions(_ transactions: [Transaction]) throws {
        for transaction in transactions {
            let txnID = transaction.id
            let cachedTxnDesc = FetchDescriptor<CachedTransaction>(
                predicate: #Predicate { cachedTxn in
                    cachedTxn.id == txnID
                }
            )
            if let cachedTxn = try modelContext.fetch(cachedTxnDesc).first {
                cachedTxn.type = transaction.type
                cachedTxn.amount = transaction.amount
                cachedTxn.currency = transaction.currency
                cachedTxn.recipientId = transaction.recipientId
                cachedTxn.recipientName = transaction.recipientName
                cachedTxn.transactionDescription =
                    transaction.description
                cachedTxn.status = transaction.status
                cachedTxn.createdAt = transaction.createdAt
            } else {
                modelContext.insert(CachedTransaction(transaction: transaction))
            }
        }
        try modelContext.save()
    }
}
