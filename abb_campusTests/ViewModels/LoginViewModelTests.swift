import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("LoginViewModel")
struct LoginViewModelTests {

    private let authService = MockAuthService()
    private let secureStorage = MockSecureStorage()
    private let preferences = MockPreferencesStore()
    private let authenticationState: AuthenticationState

    init() {
        authenticationState = AuthenticationState(
            secureStorage: secureStorage,
            authService: authService
        )
        authenticationState.selectRole(.student)
    }

    private func makeSUT(
        email: String = "student@abb.local",
        password: String = "Password123!"
    ) -> LoginViewModel {
        let viewModel = LoginViewModel(
            authenticationState: authenticationState,
            authService: authService,
            preferences: preferences
        )
        viewModel.email = email
        viewModel.password = password
        return viewModel
    }

    // MARK: - Success

    @Test("Successful login starts a session and stores the token")
    func loginSuccess() async {
        authService.loginResult = .success(.stub(token: "abc123"))
        let sut = makeSUT(email: "  student@abb.local ")

        await sut.login()

        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
        #expect(authenticationState.isAuthenticated)
        #expect(authenticationState.currentUser?.firstName == "Ceyhun")
        #expect(secureStorage.storedString() == "abc123")
        #expect(authService.lastLoginEmail == "student@abb.local")
        #expect(authService.lastLoginRole == .student)
    }

    @Test("Successful login remembers the email for the next launch")
    func loginRemembersEmail() async {
        let sut = makeSUT()

        await sut.login()

        #expect(preferences.lastLoginEmail == "student@abb.local")
    }

    @Test("Email field is prefilled from preferences")
    func emailPrefilledFromPreferences() {
        preferences.lastLoginEmail = "saved@abb.local"

        let sut = LoginViewModel(
            authenticationState: authenticationState,
            authService: authService,
            preferences: preferences
        )

        #expect(sut.email == "saved@abb.local")
        #expect(sut.password.isEmpty)
    }

    // MARK: - Errors

    @Test("Server error is shown and no session is started")
    func loginServerError() async {
        authService.loginResult = .failure(
            NetworkError.serverError(
                statusCode: 422,
                message: "Bu məlumatlarla hesab tapılmadı."
            )
        )
        let sut = makeSUT()

        await sut.login()

        #expect(sut.errorMessage == "Bu məlumatlarla hesab tapılmadı.")
        #expect(sut.isLoading == false)
        #expect(authenticationState.isAuthenticated == false)
        #expect(secureStorage.storage.isEmpty)
        #expect(preferences.lastLoginEmail == nil)
    }

    @Test("No internet connection shows a readable message")
    func loginNoConnection() async {
        authService.loginResult = .failure(NetworkError.noConnection)
        let sut = makeSUT()

        await sut.login()

        #expect(sut.errorMessage == "İnternet bağlantısı yoxdur.")
        #expect(authenticationState.isAuthenticated == false)
    }

    @Test("Keychain failure keeps the user signed out")
    func loginKeychainFailure() async {
        secureStorage.saveError = KeychainServiceError.unexpectedStatus(-1)
        let sut = makeSUT()

        await sut.login()

        #expect(sut.errorMessage != nil)
        #expect(authenticationState.isAuthenticated == false)
    }

    // MARK: - Validation

    @Test(
        "Invalid input is rejected before calling the API",
        arguments: [
            ("", "Password123!", ValidationMessage.emptyEmail),
            ("   ", "Password123!", ValidationMessage.emptyEmail),
            ("student.abb.local", "Password123!", ValidationMessage.invalidEmail),
            ("student@abb.local", "", ValidationMessage.emptyPassword),
            ("student@abb.local", "12345", ValidationMessage.shortPassword)
        ]
    )
    func validation(email: String, password: String, expectedMessage: String) async {
        let sut = makeSUT(email: email, password: password)

        await sut.login()

        #expect(sut.errorMessage == expectedMessage)
        #expect(authService.loginCallCount == 0)
    }

    @Test("Login without a selected role shows an error")
    func loginWithoutRole() async {
        let state = AuthenticationState(
            secureStorage: secureStorage,
            authService: authService
        )
        let sut = LoginViewModel(
            authenticationState: state,
            authService: authService,
            preferences: preferences
        )
        sut.email = "student@abb.local"
        sut.password = "Password123!"

        await sut.login()

        #expect(sut.errorMessage == ValidationMessage.roleNotSelected)
        #expect(authService.loginCallCount == 0)
    }

    @Test("Forgot password sheet is presented on request")
    func showForgotPassword() {
        let sut = makeSUT()

        sut.showForgotPassword()

        #expect(sut.isForgotPasswordPresented)
    }
}
