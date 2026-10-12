import Foundation

protocol PreferencesStore: AnyObject {
    var lastLoginEmail: String? { get set }
}

final class UserDefaultsPreferencesStore: PreferencesStore {

    private enum Key {
        static let lastLoginEmail = "lastLoginEmail"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var lastLoginEmail: String? {
        get {
            defaults.string(forKey: Key.lastLoginEmail)
        }
        set {
            defaults.set(newValue, forKey: Key.lastLoginEmail)
        }
    }
}
