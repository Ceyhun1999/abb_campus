import Foundation
@testable import abb_campus

final class MockAuthService: AuthService {

    var loginResult: Result<LoginResponse, Error> = .success(.stub())
    var meResult: Result<User, Error> = .success(.stub())
    var logoutError: Error?
    var changePasswordError: Error?
    var changePasswordDelay: Duration?

    private(set) var loginCallCount = 0
    private(set) var lastLoginEmail: String?
    private(set) var lastLoginPassword: String?
    private(set) var lastLoginRole: UserRole?
    private(set) var meTokens: [String] = []
    private(set) var logoutTokens: [String] = []
    private(set) var changePasswordRequests: [(token: String, request: ChangePasswordRequest)] = []

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

    func changePassword(token: String, request: ChangePasswordRequest) async throws {
        changePasswordRequests.append((token, request))

        if let changePasswordDelay {
            try await Task.sleep(for: changePasswordDelay)
        }

        if let changePasswordError {
            throw changePasswordError
        }
    }
}
