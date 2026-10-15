import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("ChangePasswordViewModel")
struct ChangePasswordViewModelTests {

    private let authService = MockAuthService()
    private let state: AuthenticationState

    init() throws {
        state = AuthenticationState(secureStorage: MockSecureStorage(), authService: authService)
        try state.startSession(user: .stub(), token: "token")
    }

    // MARK: - Helpers

    private func makeSUT(current: String = "Password123!", new: String = "NewPass456!", confirmation: String? = nil) -> ChangePasswordViewModel {
        let sut = ChangePasswordViewModel(authenticationState: state)
        sut.currentPassword = current
        sut.newPassword = new
        sut.passwordConfirmation = confirmation ?? new
        return sut
    }

    // MARK: - Save

    @Test("Valid form sends the request with the session token")
    func success() async throws {
        let sut = makeSUT()

        await sut.save()

        let sent = try #require(authService.changePasswordRequests.first)
        #expect(sent.token == "token")
        #expect(sent.request == ChangePasswordRequest(
            currentPassword: "Password123!", password: "NewPass456!", passwordConfirmation: "NewPass456!"
        ))
        #expect(sut.isCompleted)
        #expect(sut.errorMessage == nil)
    }

    @Test(
        "Invalid input is rejected before the request",
        arguments: [
            ("", "NewPass456!", "NewPass456!", ValidationMessage.emptyCurrentPassword),
            ("Password123!", "short", "short", ValidationMessage.shortNewPassword),
            ("Password123!", "NewPass456!", "Other4567!", ValidationMessage.passwordsDoNotMatch),
            ("Password123!", "Password123!", "Password123!", ValidationMessage.samePassword)
        ]
    )
    func validation(current: String, new: String, confirmation: String, message: String) async {
        let sut = makeSUT(current: current, new: new, confirmation: confirmation)

        await sut.save()

        #expect(sut.errorMessage == message)
        #expect(authService.changePasswordRequests.isEmpty)
        #expect(sut.isCompleted == false)
    }

    @Test("Server error is shown and the form stays open")
    func serverError() async {
        authService.changePasswordError = NetworkError.serverError(statusCode: 422, message: "Cari şifrə yanlışdır.")
        let sut = makeSUT()

        await sut.save()

        #expect(sut.errorMessage == "Cari şifrə yanlışdır.")
        #expect(sut.isCompleted == false)
    }

    @Test("A second tap while saving sends one request")
    func doubleTap() async {
        authService.changePasswordDelay = .milliseconds(100)
        let sut = makeSUT()

        async let first: Void = sut.save()
        async let second: Void = sut.save()
        _ = await (first, second)

        #expect(authService.changePasswordRequests.count == 1)
    }

    // MARK: - Profile

    @Test("Profile opens the change password form")
    func profileOpensForm() {
        let profile = ProfileViewModel(authenticationState: state)

        profile.showChangePassword()

        #expect(profile.isChangePasswordPresented)
        #expect(profile.changePasswordViewModel != nil)
    }
}
