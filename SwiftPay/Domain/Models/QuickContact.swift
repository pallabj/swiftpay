import Foundation

struct QuickContact: Identifiable, Sendable {
    let id: String
    let name: String
    let phone: String
    let lastTransactionDate: Date
}
