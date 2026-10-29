import Foundation

struct Wallet: Codable, Identifiable {
    let id: String
    let userId: String
    let balance: Decimal
    let currency: String
    let updatedAt: Date
}
