import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("AuthenticationState")
struct AuthenticationStateTests {

    private let authService = MockAuthService()
    private let secureStorage = MockSecureStorage()

    private func makeSUT() -> AuthenticationState {
        AuthenticationState(
            secureStorage: secureStorage,
            authService: authService
        )
    }

    @Test("Without a saved token the user stays signed out")
    func restoreWithoutToken() async {
        let sut = makeSUT()

        await sut.restoreSession()

        #expect(sut.isAuthenticated == false)
        #expect(sut.isRestoringSession == false)
        #expect(authService.meTokens.isEmpty)
    }

    @Test("A valid saved token restores the user")
    func restoreWithValidToken() async {
        secureStorage.storage["authToken"] = Data("saved-token".utf8)
        authService.meResult = .success(.stub(firstName: "Aysel"))
        let sut = makeSUT()

        await sut.restoreSession()

        #expect(sut.session == Session(user: .stub(firstName: "Aysel"), token: "saved-token"))
        #expect(sut.isAuthenticated)
        #expect(sut.currentUser?.firstName == "Aysel")
        #expect(authService.meTokens == ["saved-token"])
    }

    @Test("An expired token is removed from storage")
    func restoreWithExpiredToken() async {
        secureStorage.storage["authToken"] = Data("expired".utf8)
        authService.meResult = .failure(NetworkError.unauthorized)
        let sut = makeSUT()

        await sut.restoreSession()

        #expect(sut.isAuthenticated == false)
        #expect(secureStorage.storage.isEmpty)
    }

    @Test("Logout clears local session even if the API call fails")
    func logoutWhenServerFails() async throws {
        authService.logoutError = NetworkError.noConnection
        let sut = makeSUT()
        sut.selectRole(.student)
        try sut.startSession(user: .stub(), token: "token")

        await sut.logout()

        #expect(sut.session == nil)
        #expect(sut.token == nil)
        #expect(sut.selectedRole == nil)
        #expect(secureStorage.storage.isEmpty)
    }
}
