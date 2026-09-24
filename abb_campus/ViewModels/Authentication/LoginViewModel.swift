import Foundation
import Observation

@MainActor
@Observable
final class LoginViewModel {

    var email: String = "student@abb.local"
    var password: String = "Password123!"
    var isLoading: Bool = false
    var errorMessage: String?

    private let authenticationState: AuthenticationState
    private let authService: any AuthService

    init(
        authenticationState: AuthenticationState,
        authService: any AuthService = DefaultAuthService()
    ) {
        self.authenticationState = authenticationState
        self.authService = authService
    }

    func login() async {

        guard !ValidationHelper.isEmpty(email) else {
            errorMessage = ValidationMessage.emptyEmail
            return
        }

        guard ValidationHelper.isValidEmail(email) else {
            errorMessage = ValidationMessage.invalidEmail
            return
        }

        guard !ValidationHelper.isEmpty(password) else {
            errorMessage = ValidationMessage.emptyPassword
            return
        }

        guard ValidationHelper.isValidPassword(password) else {
            errorMessage = ValidationMessage.shortPassword
            return
        }

        guard let role = authenticationState.selectedRole else {
            errorMessage = "Rol seçilməyib."
            return
        }

        errorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let loginResult = try await authService.login(
                email: email,
                password: password,
                role: role
            )

            try authenticationState.startSession(
                user: loginResult.data.user,
                token: loginResult.data.token
            )

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
