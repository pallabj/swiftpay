import Foundation
import Testing
@testable import SwiftPay

private final class InMemoryThemeModeStore: ThemeModeStoring, @unchecked Sendable {
    var value: ThemeMode
    var saveCount = 0

    init(value: ThemeMode = .system) {
        self.value = value
    }

    func loadMode() -> ThemeMode { value }
    func saveMode(_ mode: ThemeMode) {
        value = mode
        saveCount += 1
    }
}

@MainActor
struct ThemeManagerTests {
    @Test func loadsPersistedModeOnInit() {
        let manager = ThemeManager(store: InMemoryThemeModeStore(value: .dark))
        #expect(manager.mode == .dark)
    }

    @Test func persistsModeChanges() {
        let store = InMemoryThemeModeStore(value: .system)
        let manager = ThemeManager(store: store)
        manager.mode = .light
        #expect(store.value == .light)
        #expect(store.saveCount == 1)
    }

    @Test func doesNotPersistRedundantAssignment() {
        let store = InMemoryThemeModeStore(value: .dark)
        let manager = ThemeManager(store: store)
        manager.mode = .dark
        #expect(store.saveCount == 0)
    }
}
