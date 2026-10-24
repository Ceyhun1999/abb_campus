import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("ForgotPasswordViewModel")
struct ForgotPasswordViewModelTests {

    private let service = MockPasswordResetService()

    // MARK: - Helpers

    private func makeSUT(
        email: String = "student@abb.local",
        role: UserRole = .student
    ) -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(
            email: email,
            role: role,
            passwordResetService: service
        )
    }

    // MARK: - Email Step

    @Test("Full flow goes email → code → new password → completed")
    func fullFlowSuccess() async {
        let sut = makeSUT()

        await sut.submit()
        #expect(sut.step == .code)

        sut.code = "123456"
        await sut.submit()
        #expect(sut.step == .newPassword)

        sut.newPassword = "NewPassword1"
        sut.passwordConfirmation = "NewPassword1"
        await sut.submit()

        #expect(sut.step == .completed)
        #expect(sut.errorMessage == nil)
        #expect(service.requestedEmails == ["student@abb.local"])
        #expect(service.verifiedCodes == ["123456"])
        #expect(service.resetPasswords == ["NewPassword1"])
    }

    @Test("Every step sends the role chosen before login")
    func sendsSelectedRole() async {
        let sut = makeSUT(email: "teacher@abb.local", role: .teacher)

        await sut.submit()
        sut.code = "123456"
        await sut.submit()
        sut.newPassword = "NewPassword1"
        sut.passwordConfirmation = "NewPassword1"
        await sut.submit()

        #expect(service.roles == [.teacher, .teacher, .teacher])
    }

    @Test("Invalid email does not request a code")
    func invalidEmail() async {
        let sut = makeSUT(email: "wrong-email")

        await sut.submit()

        #expect(sut.step == .email)
        #expect(sut.errorMessage == ValidationMessage.invalidEmail)
        #expect(service.requestedEmails.isEmpty)
    }

    @Test("Server error keeps the user on the same step")
    func requestCodeFailure() async {
        service.requestCodeError = NetworkError.serverError(
            statusCode: 500,
            message: "Server xətası"
        )
        let sut = makeSUT()

        await sut.submit()

        #expect(sut.step == .email)
        #expect(sut.errorMessage == "Server xətası")
        #expect(sut.isLoading == false)
    }

    // MARK: - Code Step

    @Test("Code must contain exactly 6 digits", arguments: ["", "12345", "12345a", "1234567"])
    func invalidCode(code: String) async {
        let sut = makeSUT()
        await sut.submit()

        sut.code = code
        await sut.submit()

        #expect(sut.step == .code)
        #expect(sut.errorMessage == ValidationMessage.invalidResetCode)
        #expect(service.verifiedCodes.isEmpty)
    }

    @Test("Wrong code from the server shows an error")
    func verifyCodeFailure() async {
        service.verifyCodeError = NetworkError.serverError(
            statusCode: 422,
            message: "Kod yanlışdır."
        )
        let sut = makeSUT()
        await sut.submit()

        sut.code = "000000"
        await sut.submit()

        #expect(sut.step == .code)
        #expect(sut.errorMessage == "Kod yanlışdır.")
    }

    // MARK: - New Password Step

    @Test("Passwords must match")
    func passwordsMismatch() async {
        let sut = await makeSUTOnNewPasswordStep()

        sut.newPassword = "NewPassword1"
        sut.passwordConfirmation = "Different1"
        await sut.submit()

        #expect(sut.step == .newPassword)
        #expect(sut.errorMessage == ValidationMessage.passwordsDoNotMatch)
        #expect(service.resetPasswords.isEmpty)
    }

    @Test("New password must have at least 8 characters")
    func shortNewPassword() async {
        let sut = await makeSUTOnNewPasswordStep()

        sut.newPassword = "short"
        sut.passwordConfirmation = "short"
        await sut.submit()

        #expect(sut.step == .newPassword)
        #expect(sut.errorMessage == ValidationMessage.shortNewPassword)
    }

    // MARK: - Navigation

    @Test("Going back returns to the previous step and clears the error")
    func goBack() async {
        let sut = makeSUT()
        await sut.submit()
        sut.code = "1"
        await sut.submit()
        #expect(sut.errorMessage != nil)

        sut.goBack()

        #expect(sut.step == .email)
        #expect(sut.errorMessage == nil)
    }

    private func makeSUTOnNewPasswordStep() async -> ForgotPasswordViewModel {
        let sut = makeSUT()
        await sut.submit()
        sut.code = "123456"
        await sut.submit()
        return sut
    }
}
