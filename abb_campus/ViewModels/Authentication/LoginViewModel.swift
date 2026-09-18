import Foundation
import Observation

@MainActor
@Observable
final class LoginViewModel {

    var email = ""
    var password = ""

    var isLoading = false
    var errorMessage: String?

    var loginData: LoginData?

    let selectedRole: UserRole

    private let authService: AuthService

    init(selectedRole: UserRole, authService: AuthService) {
        self.selectedRole = selectedRole
        self.authService = authService
    }

    var isLoginEnabled: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !password.isEmpty && !isLoading
    }

    func login() async {
        errorMessage = nil

        guard isLoginEnabled else {
            errorMessage = "E-poçt və şifrəni daxil edin."
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let response = try await authService.login(
                email: email,
                password: password
            )

            guard response.data.user.role == selectedRole else {
                errorMessage = "Seçilmiş rol hesabın rolu ilə uyğun gəlmir."
                return
            }

            loginData = response.data

        } catch {
            errorMessage = error.localizedDescription
        }
    }

}
