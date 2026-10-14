import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {

    var isLogoutConfirmationPresented = false
    var isChangePasswordPresented = false
    private(set) var isLoggingOut = false
    private(set) var changePasswordViewModel: ChangePasswordViewModel?

    private let authenticationState: AuthenticationState

    init(authenticationState: AuthenticationState) {
        self.authenticationState = authenticationState
    }

    var firstName: String {
        authenticationState.currentUser?.firstName ?? ""
    }

    var lastName: String {
        authenticationState.currentUser?.lastName ?? ""
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var email: String {
        authenticationState.currentUser?.email ?? ""
    }

    var roleTitle: String {
        authenticationState.currentUser?.role.title ?? ""
    }

    // MARK: - Password

    func showChangePassword() {
        changePasswordViewModel = ChangePasswordViewModel(authenticationState: authenticationState)
        isChangePasswordPresented = true
    }

    // MARK: - Logout

    func requestLogout() {
        isLogoutConfirmationPresented = true
    }

    func logout() async {
        guard !isLoggingOut else {
            return
        }

        isLoggingOut = true

        defer {
            isLoggingOut = false
        }

        await authenticationState.logout()
    }
}
