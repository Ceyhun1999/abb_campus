import Foundation
import Observation

@MainActor
@Observable
final class AuthenticationState {

    private(set) var selectedRole: UserRole?
    private(set) var currentUser: User?
    private(set) var token: String?
    private(set) var isRestoringSession = false

    private let keychainService: KeychainService
    private let authService: any AuthService

    private let tokenAccount = "authToken"

    init(
        keychainService: KeychainService = KeychainService(),
        authService: any AuthService = DefaultAuthService()
    ) {
        self.keychainService = keychainService
        self.authService = authService
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

        try keychainService.save(
            tokenData,
            for: tokenAccount
        )

        currentUser = user
        self.token = token
    }

    func restoreSession() async {
        isRestoringSession = true

        defer {
            isRestoringSession = false
        }

        do {
            guard let data = try keychainService.read(
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

        } catch {
            try? keychainService.delete(
                for: tokenAccount
            )

            currentUser = nil
            token = nil
        }
    }

    func logout() throws {
        try keychainService.delete(
            for: tokenAccount
        )

        selectedRole = nil
        currentUser = nil
        token = nil
    }
}
