import Foundation
import SwiftData

@Model
final class CachedAuthToken {
    @Attribute(.unique) var id: String
    var value: String
    var savedAt: Date

    init(value: String, savedAt: Date = .now) {
        id = "current-session"
        self.value = value
        self.savedAt = savedAt
    }
}
