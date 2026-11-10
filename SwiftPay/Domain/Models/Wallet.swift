import Foundation

struct Wallet: Codable, Identifiable {
    let id: String
    let userId: String
    var balance: Decimal
    var currency: String
    var updatedAt: Date
}
