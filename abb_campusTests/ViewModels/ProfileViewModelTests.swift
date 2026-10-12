import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("ProfileViewModel & StudentHomeViewModel")
struct ProfileViewModelTests {

    private let authService = MockAuthService()
    private let secureStorage = MockSecureStorage()
    private let state: AuthenticationState

    init() throws {
        state = AuthenticationState(
            secureStorage: secureStorage,
            authService: authService
        )
        try state.startSession(user: .stub(), token: "token")
    }

    @Test("Profile shows user information")
    func userInfo() {
        let sut = ProfileViewModel(authenticationState: state)

        #expect(sut.fullName == "Ceyhun Rzayev")
        #expect(sut.initials == "CR")
        #expect(sut.email == "student@abb.local")
        #expect(sut.roleTitle == "Tələbə")
    }

    @Test("Logout clears the session and revokes the token")
    func logout() async {
        let sut = ProfileViewModel(authenticationState: state)

        sut.requestLogout()
        #expect(sut.isLogoutConfirmationPresented)

        await sut.logout()

        #expect(state.isAuthenticated == false)
        #expect(authService.logoutTokens == ["token"])
        #expect(secureStorage.storage.isEmpty)
        #expect(sut.isLoggingOut == false)
    }

    @Test("Home greeting uses the first name")
    func homeGreeting() {
        let sut = StudentHomeViewModel(authenticationState: state)

        #expect(sut.greeting == "Salam, Ceyhun!")
    }

    @Test("Home greeting falls back when there is no user")
    func homeGreetingWithoutUser() async {
        await state.logout()
        let sut = StudentHomeViewModel(authenticationState: state)

        #expect(sut.greeting == "Salam!")
    }
}
