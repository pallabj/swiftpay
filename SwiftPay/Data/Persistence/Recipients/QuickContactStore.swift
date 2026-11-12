import Foundation
import SwiftData

@ModelActor
actor QuickContactStore {
    func fetchRecentContacts() throws -> [QuickContact] {
        let descriptor = FetchDescriptor<CachedQuickRecipient>(
            sortBy: [
                SortDescriptor(\CachedQuickRecipient.lastTransactionDate, order: .reverse),
                SortDescriptor(\CachedQuickRecipient.recipientId),
            ]
        )
        return try modelContext.fetch(descriptor).map { $0.toQuickContact() }
    }

    func recordSuccessfulTransfer(_ transaction: Transaction) throws {
        guard
            let recipientId = transaction.recipientId,
            let name = transaction.recipientName,
            let phone = transaction.recipientPhone
        else {
            return
        }

        let descriptor = FetchDescriptor<CachedQuickRecipient>(
            predicate: #Predicate { contact in
                contact.recipientId == recipientId
            }
        )

        if let contact = try modelContext.fetch(descriptor).first {
            contact.name = name
            contact.phone = phone
            contact.lastTransactionDate = transaction.createdAt
        } else {
            modelContext.insert(
                CachedQuickRecipient(
                    recipientId: recipientId,
                    name: name,
                    phone: phone,
                    lastTransactionDate: transaction.createdAt
                )
            )
        }

        try modelContext.save()
    }

    func clear() throws {
        let contacts = try modelContext.fetch(
            FetchDescriptor<CachedQuickRecipient>()
        )
        contacts.forEach(modelContext.delete)
        try modelContext.save()
    }
}
