import Foundation

struct TransactionPage: Decodable {
    let transactions: [Transaction]
    let pagination: TransactionPagination
}

struct TransactionPagination: Decodable {
    let limit: Int
    let hasMore: Bool
    let nextCursor: String?
}
