import SwiftUI

/// Semantic color and gradient tokens for the app's appearance.
///
/// Conform to this protocol to define an alternate brand palette. The default
/// implementation used by the app is `SwiftPayPalette`.
protocol ThemePalette: Sendable {
    // Brand
    var accent: Color { get }
    var accentSecondary: Color { get }
    var onAccent: Color { get }
    var accentGradient: LinearGradient { get }
    var accentHorizontalGradient: LinearGradient { get }
    var accentGlow: Color { get }

    // Surfaces
    var cardBackground: Color { get }
    var fieldBackground: Color { get }
    var fieldBorder: Color { get }
    var cardBorder: Color { get }
    var bannerGradient: LinearGradient { get }
    var shadow: Color { get }

    // Status
    var success: Color { get }
    var successBackground: Color { get }
    var danger: Color { get }
    var dangerBackground: Color { get }
}

/// The default SwiftPay brand palette.
///
/// This is the single place to change the app's brand colors. To ship a
/// different theme, provide an alternate `ThemePalette` conformance.
struct SwiftPayPalette: ThemePalette {
    private enum Palette {
        static let accentLight = Color(hex: 0x007AFF)
        static let accentDark = Color(hex: 0x0A84FF)

        static let accentSecondaryLight = Color(hex: 0x5856D6)
        static let accentSecondaryDark = Color(hex: 0x5E5CE6)

        static let successLight = Color(hex: 0x34C759)
        static let successDark = Color(hex: 0x30D158)

        static let dangerLight = Color(hex: 0xFF3B30)
        static let dangerDark = Color(hex: 0xFF453A)
    }

    let accent = Color(light: Palette.accentLight, dark: Palette.accentDark)
    let accentSecondary = Color(light: Palette.accentSecondaryLight, dark: Palette.accentSecondaryDark)
    let onAccent = Color.white

    var accentGradient: LinearGradient {
        LinearGradient(colors: [accent, accentSecondary], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var accentHorizontalGradient: LinearGradient {
        LinearGradient(colors: [accent, accentSecondary], startPoint: .leading, endPoint: .trailing)
    }

    var accentGlow: Color {
        Color(light: Palette.accentLight.opacity(0.08), dark: Palette.accentDark.opacity(0.18))
    }

    let cardBackground = Color(light: Color.gray.opacity(0.08), dark: Color.white.opacity(0.08))
    let fieldBackground = Color(light: Color.gray.opacity(0.10), dark: Color.white.opacity(0.10))

    var fieldBorder: Color {
        Color(light: Palette.accentLight.opacity(0.12), dark: Palette.accentDark.opacity(0.28))
    }

    var cardBorder: Color {
        Color(light: Palette.accentLight.opacity(0.10), dark: Palette.accentDark.opacity(0.22))
    }

    var bannerGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(light: Palette.accentLight.opacity(0.10), dark: Palette.accentDark.opacity(0.22)),
                Color(light: Palette.accentSecondaryLight.opacity(0.06), dark: Palette.accentSecondaryDark.opacity(0.16)),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    let shadow = Color(light: Color.black.opacity(0.06), dark: Color.black.opacity(0.35))

    let success = Color(light: Palette.successLight, dark: Palette.successDark)
    var successBackground: Color {
        Color(light: Palette.successLight.opacity(0.12), dark: Palette.successDark.opacity(0.20))
    }

    let danger = Color(light: Palette.dangerLight, dark: Palette.dangerDark)
    var dangerBackground: Color {
        Color(light: Palette.dangerLight.opacity(0.10), dark: Palette.dangerDark.opacity(0.20))
    }
}

/// The active palette instance used by static `AppTheme` tokens.
enum ThemePaletteProvider {
    static let current: ThemePalette = SwiftPayPalette()
}
