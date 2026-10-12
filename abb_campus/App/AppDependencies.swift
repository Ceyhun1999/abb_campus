import SwiftUI

struct AppDependencies {

    let authService: any AuthService
    let passwordResetService: any PasswordResetService
    let dashboardService: any EmployeeDashboardService
    let studentDirectoryService: any StudentDirectoryService
    let teacherService: any TeacherService
    let groupService: any GroupService
    let announcementService: any AnnouncementService
    let secureStorage: any SecureStorage
    let preferences: any PreferencesStore
    let tokenStore: TokenStore

    @MainActor
    func makeAuthenticationState() -> AuthenticationState {
        AuthenticationState(
            secureStorage: secureStorage,
            authService: authService,
            tokenStore: tokenStore
        )
    }
}

extension AppDependencies {

    static var live: AppDependencies {
        let tokenStore = TokenStore()
        let networkService = DefaultNetworkService(tokenProvider: tokenStore)

        return AppDependencies(
            authService: DefaultAuthService(
                networkService: networkService
            ),
            passwordResetService: DefaultPasswordResetService(
                networkService: networkService
            ),
            dashboardService: DefaultEmployeeDashboardService(
                networkService: networkService
            ),
            studentDirectoryService: DefaultStudentDirectoryService(
                networkService: networkService
            ),
            teacherService: DefaultTeacherService(
                networkService: networkService
            ),
            groupService: DefaultGroupService(
                networkService: networkService
            ),
            announcementService: DefaultAnnouncementService(
                networkService: networkService
            ),
            secureStorage: KeychainService(),
            preferences: UserDefaultsPreferencesStore(),
            tokenStore: tokenStore
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
