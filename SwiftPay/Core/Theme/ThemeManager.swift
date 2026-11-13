import Foundation
import Observation

/// Holds and persists the user's chosen appearance mode.
///
/// Inject a `ThemeModeStoring` implementation for testing or alternate storage.
@MainActor
@Observable
final class ThemeManager {
    private let store: any ThemeModeStoring

    /// The appearance mode currently in use.
    var mode: ThemeMode {
        didSet {
            guard mode != oldValue else { return }
            store.saveMode(mode)
        }
    }

    init(store: any ThemeModeStoring = UserDefaultsThemeModeStore()) {
        self.store = store
        self.mode = store.loadMode()
    }
}
