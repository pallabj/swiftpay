import Foundation
import SwiftData

@Model
final class CachedQuickRecipient {
    @Attribute(.unique) var recipientId: String
    var name: String
    var phone: String
    var lastTransactionDate: Date

    init(
        recipientId: String,
        name: String,
        phone: String,
        lastTransactionDate: Date
    ) {
        self.recipientId = recipientId
        self.name = name
        self.phone = phone
        self.lastTransactionDate = lastTransactionDate
    }

    func toQuickContact() -> QuickContact {
        QuickContact(
            id: recipientId,
            name: name,
            phone: phone,
            lastTransactionDate: lastTransactionDate
        )
    }
}
