import Foundation
import Observation

/// The appearance the user chose. It is applied to the whole app and remembered between launches.
@MainActor
@Observable
final class AppearanceSettings {

    private(set) var mode: AppearanceMode

    private let preferences: any PreferencesStore

    init(preferences: any PreferencesStore) {
        self.preferences = preferences
        self.mode = preferences.appearanceMode
    }

    func select(_ mode: AppearanceMode) {
        guard mode != self.mode else {
            return
        }

        self.mode = mode
        preferences.setAppearanceMode(mode)
    }
}
