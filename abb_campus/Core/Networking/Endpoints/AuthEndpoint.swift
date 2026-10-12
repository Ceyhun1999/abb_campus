import Foundation

enum AuthEndpoint {
    case login(LoginRequest)
    case me(token: String)
    case logout(token: String)
    case forgotPassword(ForgotPasswordRequest)
    case verifyResetCode(VerifyResetCodeRequest)
    case resetPassword(ResetPasswordRequest)
}

extension AuthEndpoint: Endpoint {

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
        }
    }

    var method: HTTPMethod {
        switch self {
        case .me:
            return .get

        case .login,
             .logout,
             .forgotPassword,
             .verifyResetCode,
             .resetPassword:
            return .post
        }
    }

    var headers: [String: String]? {
        switch self {
        case .me(let token),
             .logout(let token):
            return HTTPHeader.authorized(token: token)

        case .login,
             .forgotPassword,
             .verifyResetCode,
             .resetPassword:
            return HTTPHeader.json
        }
    }

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

        case .me,
             .logout:
            return nil
        }
    }
}
