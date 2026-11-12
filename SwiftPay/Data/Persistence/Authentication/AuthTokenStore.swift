import Foundation
import SwiftData

@ModelActor
actor AuthTokenStore {
    func fetchToken() throws -> String? {
        let tokenID = "current-session"
        var descriptor = FetchDescriptor<CachedAuthToken>(
            predicate: #Predicate { $0.id == tokenID }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.value
    }

    func saveToken(_ value: String) throws {
        let tokenID = "current-session"
        let descriptor = FetchDescriptor<CachedAuthToken>(
            predicate: #Predicate { $0.id == tokenID }
        )

        if let cachedToken = try modelContext.fetch(descriptor).first {
            cachedToken.value = value
            cachedToken.savedAt = .now
        } else {
            modelContext.insert(CachedAuthToken(value: value))
        }

        try modelContext.save()
    }

    func clearToken() throws {
        let cachedTokens = try modelContext.fetch(
            FetchDescriptor<CachedAuthToken>()
        )
        cachedTokens.forEach(modelContext.delete)
        try modelContext.save()
    }
}
