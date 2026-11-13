import SwiftUI

/// Semantic theme tokens used throughout the app.
///
/// Tokens resolve from `ThemePaletteProvider.current`. To re-theme the app,
/// update `SwiftPayPalette` (or supply a different `ThemePalette`) in one place.
/// System semantic colors (`.primary`, `.secondary`, system backgrounds) are
/// intentionally left to SwiftUI/UIKit for native adaptation.
enum AppTheme {
    private static var palette: ThemePalette { ThemePaletteProvider.current }

    // MARK: - Brand
    static var accent: Color { palette.accent }
    static var accentSecondary: Color { palette.accentSecondary }
    static var onAccent: Color { palette.onAccent }
    static var accentGradient: LinearGradient { palette.accentGradient }
    static var accentHorizontalGradient: LinearGradient { palette.accentHorizontalGradient }
    static var accentGlow: Color { palette.accentGlow }

    // MARK: - Surfaces
    static var cardBackground: Color { palette.cardBackground }
    static var fieldBackground: Color { palette.fieldBackground }
    static var fieldBorder: Color { palette.fieldBorder }
    static var cardBorder: Color { palette.cardBorder }
    static var bannerGradient: LinearGradient { palette.bannerGradient }
    static var shadow: Color { palette.shadow }

    // MARK: - Status
    static var success: Color { palette.success }
    static var successBackground: Color { palette.successBackground }
    static var danger: Color { palette.danger }
    static var dangerBackground: Color { palette.dangerBackground }
}
