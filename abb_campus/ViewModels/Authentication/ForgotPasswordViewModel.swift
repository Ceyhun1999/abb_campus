import Foundation
import Observation

@MainActor
@Observable
final class ForgotPasswordViewModel {

    enum Step: Equatable {
        case email
        case code
        case newPassword
        case completed
    }

    var email: String
    var code: String = ""
    var newPassword: String = ""
    var passwordConfirmation: String = ""

    private(set) var step: Step = .email
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let passwordResetService: any PasswordResetService

    init(
        email: String = "",
        passwordResetService: any PasswordResetService
    ) {
        self.email = email
        self.passwordResetService = passwordResetService
    }

    func dismissError() {
        errorMessage = nil
    }

    func submit() async {
        guard !isLoading else {
            return
        }

        switch step {
        case .email:
            await requestCode()

        case .code:
            await verifyCode()

        case .newPassword:
            await resetPassword()

        case .completed:
            break
        }
    }

    func goBack() {
        errorMessage = nil

        switch step {
        case .code:
            step = .email

        case .newPassword:
            step = .code

        case .email, .completed:
            break
        }
    }

    private func requestCode() async {
        if let emailError = ValidationHelper.emailError(email) {
            errorMessage = emailError
            return
        }

        await perform(nextStep: .code) { [self] in
            try await passwordResetService.requestCode(
                email: trimmedEmail
            )
        }
    }

    private func verifyCode() async {
        guard ValidationHelper.isValidResetCode(code) else {
            errorMessage = ValidationMessage.invalidResetCode
            return
        }

        await perform(nextStep: .newPassword) { [self] in
            try await passwordResetService.verifyCode(
                email: trimmedEmail,
                code: code
            )
        }
    }

    private func resetPassword() async {
        guard ValidationHelper.isValidNewPassword(newPassword) else {
            errorMessage = ValidationMessage.shortNewPassword
            return
        }

        guard newPassword == passwordConfirmation else {
            errorMessage = ValidationMessage.passwordsDoNotMatch
            return
        }

        await perform(nextStep: .completed) { [self] in
            try await passwordResetService.resetPassword(
                email: trimmedEmail,
                code: code,
                password: newPassword
            )
        }
    }

    private func perform(
        nextStep: Step,
        operation: () async throws -> Void
    ) async {
        errorMessage = nil
        isLoading = true

        defer {
            isLoading = false
        }

        do {
            try await operation()
            step = nextStep
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
