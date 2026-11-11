import Foundation
import SwiftData

@Model
final class CachedWallet {
    @Attribute(.unique) var id: String
    var userId: String
    var balance: Decimal
    var currency: String
    var updatedAt: Date

    init(wallet: Wallet) {
        self.id = wallet.id
        self.userId = wallet.userId
        self.balance = wallet.balance
        self.currency = wallet.currency
        self.updatedAt = wallet.updatedAt
    }

    func toWallet() -> Wallet {
        Wallet(
            id: id,
            userId: userId,
            balance: balance,
            currency: currency,
            updatedAt: updatedAt
        )
    }
}
