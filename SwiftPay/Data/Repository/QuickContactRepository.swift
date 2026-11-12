import Foundation

struct QuickContactRepository {
    private let store: QuickContactStore

    init(store: QuickContactStore) {
        self.store = store
    }

    func fetchRecentContacts() async throws -> [QuickContact] {
        try await store.fetchRecentContacts()
    }

    func recordSuccessfulTransfer(_ transaction: Transaction) async throws {
        try await store.recordSuccessfulTransfer(transaction)
    }
}
