import Foundation
import Observation

@MainActor
@Observable
final class AuthenticationState {

    private(set) var selectedRole: UserRole?
    private(set) var currentUser: User?
    private(set) var token: String?
    private(set) var isRestoringSession = true

    private let secureStorage: any SecureStorage
    private let authService: any AuthService
    private let tokenStore: TokenStore

    private let tokenAccount = "authToken"

    init(
        secureStorage: any SecureStorage,
        authService: any AuthService,
        tokenStore: TokenStore = TokenStore()
    ) {
        self.secureStorage = secureStorage
        self.authService = authService
        self.tokenStore = tokenStore
    }

    var isAuthenticated: Bool {
        currentUser != nil && token != nil
    }

    func selectRole(_ role: UserRole) {
        selectedRole = role
    }

    func startSession(
        user: User,
        token: String
    ) throws {
        let tokenData = Data(token.utf8)

        try secureStorage.save(
            tokenData,
            for: tokenAccount
        )

        currentUser = user
        self.token = token
        tokenStore.token = token
    }

    func restoreSession() async {
        isRestoringSession = true

        defer {
            isRestoringSession = false
        }

        do {
            guard let data = try secureStorage.read(
                for: tokenAccount
            ) else {
                return
            }

            guard let savedToken = String(
                data: data,
                encoding: .utf8
            ) else {
                throw KeychainServiceError.invalidData
            }

            let user = try await authService.me(
                token: savedToken
            )

            currentUser = user
            token = savedToken
            tokenStore.token = savedToken

        } catch {
            clearSession()
        }
    }

    func logout() async {
        if let token {
            try? await authService.logout(token: token)
        }

        clearSession()
    }

    private func clearSession() {
        try? secureStorage.delete(
            for: tokenAccount
        )

        selectedRole = nil
        currentUser = nil
        token = nil
        tokenStore.token = nil
    }
}
