import Foundation
import Observation

@MainActor
@Observable
final class LoginViewModel {

    var email: String
    var password: String = ""
    var isForgotPasswordPresented = false
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    private let authenticationState: AuthenticationState
    private let authService: any AuthService
    private let preferences: any PreferencesStore

    init(
        authenticationState: AuthenticationState,
        authService: any AuthService,
        preferences: any PreferencesStore
    ) {
        self.authenticationState = authenticationState
        self.authService = authService
        self.preferences = preferences
        self.email = authenticationState.selectedRole
            .flatMap { preferences.lastLoginEmail(for: $0) } ?? ""
    }

    func dismissError() {
        errorMessage = nil
    }

    // MARK: - Login

    var selectedRole: UserRole? {
        authenticationState.selectedRole
    }

    func login() async {
        guard !isLoading else {
            return
        }

        if let validationError = validate() {
            errorMessage = validationError
            return
        }

        guard let role = selectedRole else {
            errorMessage = ValidationMessage.roleNotSelected
            return
        }

        errorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        let trimmedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        do {
            let loginResult = try await authService.login(
                email: trimmedEmail,
                password: password,
                role: role
            )

            try authenticationState.startSession(
                user: loginResult.data.user,
                token: loginResult.data.token
            )

            preferences.setLastLoginEmail(trimmedEmail, for: role)

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Navigation

    func showForgotPassword() {
        isForgotPasswordPresented = true
    }

    // MARK: - Validation

    private func validate() -> String? {
        if let emailError = ValidationHelper.emailError(email) {
            return emailError
        }

        if ValidationHelper.isEmpty(password) {
            return ValidationMessage.emptyPassword
        }

        if !ValidationHelper.isValidPassword(password) {
            return ValidationMessage.shortPassword
        }

        return nil
    }
}
