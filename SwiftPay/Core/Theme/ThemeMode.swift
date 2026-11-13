import SwiftUI

/// The appearance the user has chosen for the app.
enum ThemeMode: String, CaseIterable, Identifiable, Sendable {
    /// Follow the system appearance.
    case system
    /// Always use the light appearance.
    case light
    /// Always use the dark appearance.
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var systemImage: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    /// The color scheme to force, or `nil` to follow the system setting.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
