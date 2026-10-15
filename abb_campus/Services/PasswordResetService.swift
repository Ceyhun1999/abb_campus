import Foundation

protocol PasswordResetService {

    func requestCode(
        email: String
    ) async throws

    func verifyCode(
        email: String,
        code: String
    ) async throws

    func resetPassword(
        email: String,
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
        email: String
    ) async throws {

        let endpoint = AuthEndpoint.forgotPassword(
            ForgotPasswordRequest(email: email)
        )

        let _: MessageResponse = try await networkService.request(
            endpoint
        )
    }

    // MARK: - Verify Code

    func verifyCode(
        email: String,
        code: String
    ) async throws {

        let endpoint = AuthEndpoint.verifyResetCode(
            VerifyResetCodeRequest(
                email: email,
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
        code: String,
        password: String
    ) async throws {

        let endpoint = AuthEndpoint.resetPassword(
            ResetPasswordRequest(
                email: email,
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
