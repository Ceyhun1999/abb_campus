import Foundation

protocol PreferencesStore: AnyObject {
    func lastLoginEmail(for role: UserRole) -> String?
    func setLastLoginEmail(_ email: String?, for role: UserRole)
}

final class UserDefaultsPreferencesStore: PreferencesStore {

    private enum Key {
        static func lastLoginEmail(for role: UserRole) -> String {
            "lastLoginEmail.\(role.rawValue)"
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func lastLoginEmail(for role: UserRole) -> String? {
        defaults.string(forKey: Key.lastLoginEmail(for: role))
    }

    func setLastLoginEmail(_ email: String?, for role: UserRole) {
        defaults.set(email, forKey: Key.lastLoginEmail(for: role))
    }
}
