import Foundation

enum AuthEndpoint {
    case login(LoginRequest)
    case me(token: String)
    case logout(token: String)
    case forgotPassword(ForgotPasswordRequest)
    case verifyResetCode(VerifyResetCodeRequest)
    case resetPassword(ResetPasswordRequest)
    case changePassword(token: String, ChangePasswordRequest)
}

extension AuthEndpoint: Endpoint {

    // MARK: - Path

    var path: String {
        switch self {
        case .login:
            return "/api/auth/login"

        case .me:
            return "/api/auth/me"

        case .logout:
            return "/api/auth/logout"

        case .forgotPassword:
            return "/api/auth/forgot-password"

        case .verifyResetCode:
            return "/api/auth/verify-reset-code"

        case .resetPassword:
            return "/api/auth/reset-password"

        case .changePassword:
            return "/api/auth/change-password"
        }
    }

    // MARK: - Method

    var method: HTTPMethod {
        switch self {
        case .me:
            return .get

        case .login,
             .logout,
             .forgotPassword,
             .verifyResetCode,
             .resetPassword,
             .changePassword:
            return .post
        }
    }

    // MARK: - Headers

    var headers: [String: String]? {
        switch self {
        case .me(let token),
             .logout(let token),
             .changePassword(let token, _):
            return HTTPHeader.authorized(token: token)

        case .login,
             .forgotPassword,
             .verifyResetCode,
             .resetPassword:
            return HTTPHeader.json
        }
    }

    // MARK: - Body

    var httpBody: (any Encodable)? {
        switch self {
        case .login(let request):
            return request

        case .forgotPassword(let request):
            return request

        case .verifyResetCode(let request):
            return request

        case .resetPassword(let request):
            return request

        case .changePassword(_, let request):
            return request

        case .me,
             .logout:
            return nil
        }
    }
}
