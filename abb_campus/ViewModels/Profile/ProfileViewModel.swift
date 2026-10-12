import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {

    var isLogoutConfirmationPresented = false
    private(set) var isLoggingOut = false

    private let authenticationState: AuthenticationState

    init(authenticationState: AuthenticationState) {
        self.authenticationState = authenticationState
    }

    var fullName: String {
        guard let user = authenticationState.currentUser else {
            return ""
        }

        return "\(user.firstName) \(user.lastName)"
    }

    var initials: String {
        guard let user = authenticationState.currentUser else {
            return ""
        }

        return [user.firstName, user.lastName]
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }

    var email: String {
        authenticationState.currentUser?.email ?? ""
    }

    var roleTitle: String {
        authenticationState.currentUser?.role.title ?? ""
    }

    func requestLogout() {
        isLogoutConfirmationPresented = true
    }

    func logout() async {
        isLoggingOut = true

        defer {
            isLoggingOut = false
        }

        await authenticationState.logout()
    }
}
