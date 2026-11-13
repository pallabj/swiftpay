# Theme module

Centralized, production-oriented appearance system for SwiftPay.

## Structure

- `ThemeMode.swift` — user-selectable appearance (`system` / `light` / `dark`) and `ColorScheme` mapping.
- `ThemePalette.swift` — semantic color/gradient token contract (`ThemePalette`) and the default brand implementation (`SwiftPayPalette`). **Change brand colors in `SwiftPayPalette` (single place).**
- `AppTheme.swift` — static token accessors used by views; resolves from `ThemePaletteProvider.current`. Prefer these tokens over ad-hoc colors.
- `Color+Theme.swift` — `Color(hex:)` and dynamic `Color(light:dark:)` (resolves per interface style, including forced schemes).
- `ThemeModeStore.swift` — persistence abstraction (`ThemeModeStoring`) and `UserDefaults` implementation (versioned key/suite, resilient to invalid values).
- `ThemeManager.swift` — `@MainActor @Observable` source of truth for the selected mode; depends on injected store for testability.
- `ThemeManagerKey.swift` — SwiftUI environment injection (`\.themeManager`) to avoid prop-drilling.

## Usage

- Inject once at the root: `AppRootView` sets `.environment(\.themeManager, ...)`, `.tint(AppTheme.accent)`, and `.preferredColorScheme(themeManager.mode.colorScheme)`.
- Read/update in views via `@Environment(\.themeManager)` (e.g. Profile appearance picker).
- Style views with `AppTheme.*` tokens; keep system semantics (`.primary`, `.secondary`, system backgrounds) for native adaptation.

## Extending

- **Rebrand:** edit token values in `SwiftPayPalette`.
- **Multiple/remote themes:** add alternate `ThemePalette` conformances and switch `ThemePaletteProvider.current` (or evolve it to a runtime-selected palette) without touching views.
- **New tokens:** add to `ThemePalette`, implement in palettes, and expose via `AppTheme`.

## Accessibility & verification

- Prefer semantic/system colors for text and backgrounds where possible.
- Verify light/dark/system modes and Dynamic Type in Simulator and with snapshot/UI tests; validate contrast for custom token pairs (accent/onAccent, status colors).
