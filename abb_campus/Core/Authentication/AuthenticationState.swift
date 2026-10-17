import Foundation
import Observation

// MARK: - Session

struct Session: Equatable {
    let user: User
    let token: String
}

@MainActor
@Observable
final class AuthenticationState {

    private(set) var selectedRole: UserRole?
    private(set) var session: Session?
    private(set) var isRestoringSession = true

    private let secureStorage: any SecureStorage
    private let authService: any AuthService
    private let tokenStore: TokenStore

    private let tokenAccount = "authToken"

    init(
        secureStorage: any SecureStorage,
        authService: any AuthService,
        tokenStore: TokenStore? = nil
    ) {
        self.secureStorage = secureStorage
        self.authService = authService
        self.tokenStore = tokenStore ?? TokenStore()
    }

    var isAuthenticated: Bool {
        session != nil
    }

    var currentUser: User? {
        session?.user
    }

    var token: String? {
        session?.token
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

        session = Session(user: user, token: token)
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

            session = Session(user: user, token: savedToken)
            tokenStore.token = savedToken

        } catch {
            clearSession()
        }
    }

    func changePassword(_ request: ChangePasswordRequest) async throws {
        guard let token else {
            throw NetworkError.unauthorized
        }

        try await authService.changePassword(token: token, request: request)
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
        session = nil
        tokenStore.token = nil
    }
}
