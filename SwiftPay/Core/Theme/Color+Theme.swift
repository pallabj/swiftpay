import SwiftUI

extension Color {
    /// Creates a colour from a 24-bit RGB hex value, for example `0x007AFF`.
    ///
    /// Hex values keep the palette in `AppTheme` readable at a glance.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    /// Creates a colour that resolves to a different value in light and dark mode.
    ///
    /// The result is a dynamic colour, so it follows the interface style the app
    /// is currently rendering in, including a style forced with
    /// `preferredColorScheme(_:)`.
    init(light: Color, dark: Color) {
        self.init(
            uiColor: UIColor { traits in
                UIColor(traits.userInterfaceStyle == .dark ? dark : light)
            }
        )
    }
}
