import Foundation

struct TransactionPage: Decodable {
    let transactions: [Transaction]
    let pagination: TransactionPagination
}

struct TransactionPagination: Decodable {
    let limit: Int
    let offset: Int
    let total: Int
    let hasMore: Bool
    let nextOffset: Int?
}
