import Foundation

struct Wallet: Codable, Identifiable, Sendable {
    let id: String
    let userId: String
    var balance: Decimal
    var currency: String
    var updatedAt: Date
}
