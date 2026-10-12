import SwiftUI

struct AppDependencies {

    let authService: any AuthService
    let passwordResetService: any PasswordResetService
    let secureStorage: any SecureStorage
    let preferences: any PreferencesStore

    @MainActor
    func makeAuthenticationState() -> AuthenticationState {
        AuthenticationState(
            secureStorage: secureStorage,
            authService: authService
        )
    }
}

extension AppDependencies {

    static var live: AppDependencies {
        let networkService = DefaultNetworkService()

        return AppDependencies(
            authService: DefaultAuthService(
                networkService: networkService
            ),
            passwordResetService: DefaultPasswordResetService(
                networkService: networkService
            ),
            secureStorage: KeychainService(),
            preferences: UserDefaultsPreferencesStore()
        )
    }

    static func current(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> AppDependencies {
        #if DEBUG
        if arguments.contains(LaunchArgument.uiTesting) {
            return .uiTesting
        }
        #endif

        return .live
    }
}

enum LaunchArgument {
    static let uiTesting = "-ui-testing"
}

extension EnvironmentValues {
    @Entry var dependencies: AppDependencies = .live
}
