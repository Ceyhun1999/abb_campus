import Foundation
import Observation

@MainActor
@Observable
final class ChangePasswordViewModel {

    var currentPassword = ""
    var newPassword = ""
    var passwordConfirmation = ""

    private(set) var isSaving = false
    private(set) var isCompleted = false
    private(set) var errorMessage: String?

    private let authenticationState: AuthenticationState

    init(authenticationState: AuthenticationState) {
        self.authenticationState = authenticationState
    }

    func dismissError() {
        errorMessage = nil
    }

    // MARK: - Save

    func save() async {
        guard !isSaving else {
            return
        }

        if let validationError {
            errorMessage = validationError
            return
        }

        errorMessage = nil
        isSaving = true

        defer {
            isSaving = false
        }

        do {
            try await authenticationState.changePassword(
                ChangePasswordRequest(
                    currentPassword: currentPassword,
                    password: newPassword,
                    passwordConfirmation: passwordConfirmation
                )
            )
            isCompleted = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var validationError: String? {
        if currentPassword.isEmpty {
            return ValidationMessage.emptyCurrentPassword
        }

        if newPassword.count < 8 {
            return ValidationMessage.shortNewPassword
        }

        if newPassword != passwordConfirmation {
            return ValidationMessage.passwordsDoNotMatch
        }

        if newPassword == currentPassword {
            return ValidationMessage.samePassword
        }

        return nil
    }
}
