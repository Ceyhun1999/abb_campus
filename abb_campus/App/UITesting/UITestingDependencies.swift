#if DEBUG
import Foundation

// Stub services used when the app is launched by UI tests (`-ui-testing`),
// so UI tests never depend on the real backend.

extension AppDependencies {

    static var uiTesting: AppDependencies {
        AppDependencies(
            authService: UITestingAuthService(),
            passwordResetService: UITestingPasswordResetService(),
            secureStorage: InMemorySecureStorage(),
            preferences: InMemoryPreferencesStore()
        )
    }
}

enum UITestingCredentials {
    static let email = "student@abb.local"
    static let password = "Password123!"
    static let token = "ui-testing-token"
}

final class UITestingAuthService: AuthService {

    private let user = User(
        id: 1,
        firstName: "Ceyhun",
        lastName: "Rzayev",
        email: UITestingCredentials.email,
        role: .student
    )

    func login(
        email: String,
        password: String,
        role: UserRole
    ) async throws -> LoginResponse {
        try await Task.sleep(for: .milliseconds(300))

        guard email == UITestingCredentials.email,
              password == UITestingCredentials.password,
              role == .student else {
            throw NetworkError.serverError(
                statusCode: 422,
                message: "Bu məlumatlarla hesab tapılmadı."
            )
        }

        return LoginResponse(
            success: true,
            data: LoginData(
                token: UITestingCredentials.token,
                user: user
            )
        )
    }

    func me(token: String) async throws -> User {
        guard token == UITestingCredentials.token else {
            throw NetworkError.unauthorized
        }

        return user
    }

    func logout(token: String) async throws {}
}

final class UITestingPasswordResetService: PasswordResetService {
    func requestCode(email: String) async throws {}
    func verifyCode(email: String, code: String) async throws {}
    func resetPassword(email: String, code: String, password: String) async throws {}
}

final class InMemorySecureStorage: SecureStorage {

    private var storage: [String: Data] = [:]

    func save(_ data: Data, for account: String) throws {
        storage[account] = data
    }

    func read(for account: String) throws -> Data? {
        storage[account]
    }

    func delete(for account: String) throws {
        storage[account] = nil
    }
}

final class InMemoryPreferencesStore: PreferencesStore {

    private var emails: [UserRole: String] = [:]

    func lastLoginEmail(for role: UserRole) -> String? {
        emails[role]
    }

    func setLastLoginEmail(_ email: String?, for role: UserRole) {
        emails[role] = email
    }
}
#endif
