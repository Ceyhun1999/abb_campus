import Foundation

protocol PasswordResetService {

    func requestCode(
        email: String,
        role: UserRole
    ) async throws

    func verifyCode(
        email: String,
        role: UserRole,
        code: String
    ) async throws

    func resetPassword(
        email: String,
        role: UserRole,
        code: String,
        password: String
    ) async throws
}

final class DefaultPasswordResetService: PasswordResetService {

    private let networkService: any NetworkService

    init(
        networkService: any NetworkService = DefaultNetworkService()
    ) {
        self.networkService = networkService
    }

    // MARK: - Request Code

    func requestCode(
        email: String,
        role: UserRole
    ) async throws {

        let endpoint = AuthEndpoint.forgotPassword(
            ForgotPasswordRequest(email: email, role: role)
        )

        let _: MessageResponse = try await networkService.request(
            endpoint
        )
    }

    // MARK: - Verify Code

    func verifyCode(
        email: String,
        role: UserRole,
        code: String
    ) async throws {

        let endpoint = AuthEndpoint.verifyResetCode(
            VerifyResetCodeRequest(
                email: email,
                role: role,
                code: code
            )
        )

        let _: MessageResponse = try await networkService.request(
            endpoint
        )
    }

    // MARK: - Reset Password

    func resetPassword(
        email: String,
        role: UserRole,
        code: String,
        password: String
    ) async throws {

        let endpoint = AuthEndpoint.resetPassword(
            ResetPasswordRequest(
                email: email,
                role: role,
                code: code,
                password: password,
                passwordConfirmation: password
            )
        )

        let _: MessageResponse = try await networkService.request(
            endpoint
        )
    }
}
