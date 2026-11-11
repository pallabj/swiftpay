import SwiftData

@Model
final class CachedTransactionPagination {
    @Attribute(.unique) var id: String
    var limit: Int
    var hasMore: Bool
    var nextCursor: String?

    init(
        id: String = "transaction-history",
        limit: Int,
        hasMore: Bool,
        nextCursor: String?
    ) {
        self.id = id
        self.limit = limit
        self.hasMore = hasMore
        self.nextCursor = nextCursor
    }

    func toPagination() -> TransactionPagination {
        TransactionPagination(
            limit: limit,
            hasMore: hasMore,
            nextCursor: nextCursor
        )
    }
}
