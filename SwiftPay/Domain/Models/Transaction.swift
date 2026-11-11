import Foundation

struct Transaction: Codable, Identifiable, Sendable {
    let id: String
    let type: String
    let amount: Decimal
    let currency: String
    let recipientId: String?
    let recipientName: String?
    let description: String
    let status: String
    let createdAt: Date
}
