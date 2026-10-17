import Foundation

protocol PreferencesStore: AnyObject {
    func lastLoginEmail(for role: UserRole) -> String?
    func setLastLoginEmail(_ email: String?, for role: UserRole)
    var appearanceMode: AppearanceMode { get }
    func setAppearanceMode(_ mode: AppearanceMode)
}

final class UserDefaultsPreferencesStore: PreferencesStore {

    private enum Key {
        static func lastLoginEmail(for role: UserRole) -> String {
            "lastLoginEmail.\(role.rawValue)"
        }

        static let appearanceMode = "appearanceMode"
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

    var appearanceMode: AppearanceMode {
        defaults.string(forKey: Key.appearanceMode).flatMap(AppearanceMode.init(rawValue:)) ?? .system
    }

    func setAppearanceMode(_ mode: AppearanceMode) {
        defaults.set(mode.rawValue, forKey: Key.appearanceMode)
    }
}
