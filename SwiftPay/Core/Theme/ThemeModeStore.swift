import Foundation

/// Persists the user's appearance choice.
protocol ThemeModeStoring: Sendable {
    func loadMode() -> ThemeMode
    func saveMode(_ mode: ThemeMode)
}

/// Stores the appearance choice in `UserDefaults`.
struct UserDefaultsThemeModeStore: ThemeModeStoring {
    static let defaultKey = "com.swiftpay.appearance.mode"
    static let defaultSuiteName = "com.swiftpay.preferences"

    private let defaults: UserDefaults
    private let key: String

    init(
        defaults: UserDefaults? = UserDefaults(suiteName: Self.defaultSuiteName) ?? .standard,
        key: String = Self.defaultKey
    ) {
        self.defaults = defaults ?? .standard
        self.key = key
    }

    func loadMode() -> ThemeMode {
        guard let rawValue = defaults.string(forKey: key),
              let mode = ThemeMode(rawValue: rawValue)
        else {
            return .system
        }
        return mode
    }

    func saveMode(_ mode: ThemeMode) {
        defaults.set(mode.rawValue, forKey: key)
    }
}
