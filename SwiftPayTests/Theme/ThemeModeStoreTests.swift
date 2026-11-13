import Foundation
import Testing
@testable import SwiftPay

struct ThemeModeStoreTests {
    private func makeStore() -> (UserDefaultsThemeModeStore, UserDefaults, String) {
        let suiteName = "com.swiftpay.tests.theme.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let key = "theme.mode"
        return (UserDefaultsThemeModeStore(defaults: defaults, key: key), defaults, suiteName)
    }

    @Test func defaultsToSystemWhenEmpty() {
        let (store, defaults, suite) = makeStore()
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(store.loadMode() == .system)
    }

    @Test func roundTripsSavedMode() {
        let (store, defaults, suite) = makeStore()
        defer { defaults.removePersistentDomain(forName: suite) }
        store.saveMode(.dark)
        #expect(store.loadMode() == .dark)
        store.saveMode(.light)
        #expect(store.loadMode() == .light)
    }

    @Test func fallsBackToSystemOnInvalidValue() {
        let (store, defaults, suite) = makeStore()
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set("neon", forKey: "theme.mode")
        #expect(store.loadMode() == .system)
    }
}
