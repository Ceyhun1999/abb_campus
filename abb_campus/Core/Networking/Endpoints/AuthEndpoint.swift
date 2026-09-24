import Foundation

enum AuthEndpoint {
    case login(LoginRequest)
    case me(token: String)
}

extension AuthEndpoint: Endpoint {

    var baseUrl: String {
        "https://campus.jeywastudio.com"
    }

    var path: String {
        switch self {
        case .login:
            return "/api/auth/login"

        case .me:
            return "/api/auth/me"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login:
            return .post

        case .me:
            return .get
        }
    }

    var headers: [String: String]? {
        switch self {
        case .login:
            return [
                HTTPHeader.contentType: ContentType.json,
                HTTPHeader.accept: ContentType.json
            ]

        case .me(let token):
            return [
                HTTPHeader.accept: ContentType.json,
                HTTPHeader.authorization: "Bearer \(token)"
            ]
        }
    }

    var httpBody: (any Encodable)? {
        switch self {
        case .login(let request):
            return request

        case .me:
            return nil
        }
    }
}
