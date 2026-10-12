import Foundation
@testable import abb_campus

final class MockAuthService: AuthService {

    var loginResult: Result<LoginResponse, Error> = .success(.stub())
    var meResult: Result<User, Error> = .success(.stub())
    var logoutError: Error?

    private(set) var loginCallCount = 0
    private(set) var lastLoginEmail: String?
    private(set) var lastLoginPassword: String?
    private(set) var lastLoginRole: UserRole?
    private(set) var meTokens: [String] = []
    private(set) var logoutTokens: [String] = []

    func login(
        email: String,
        password: String,
        role: UserRole
    ) async throws -> LoginResponse {
        loginCallCount += 1
        lastLoginEmail = email
        lastLoginPassword = password
        lastLoginRole = role

        return try loginResult.get()
    }

    func me(token: String) async throws -> User {
        meTokens.append(token)

        return try meResult.get()
    }

    func logout(token: String) async throws {
        logoutTokens.append(token)

        if let logoutError {
            throw logoutError
        }
    }
}
