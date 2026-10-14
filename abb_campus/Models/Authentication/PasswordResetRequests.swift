import Foundation

struct ForgotPasswordRequest: Encodable {
    let email: String
}

struct VerifyResetCodeRequest: Encodable {
    let email: String
    let code: String
}

struct ResetPasswordRequest: Encodable {
    let email: String
    let code: String
    let password: String
    let passwordConfirmation: String

    enum CodingKeys: String, CodingKey {
        case email
        case code
        case password
        case passwordConfirmation = "password_confirmation"
    }
}

struct ChangePasswordRequest: Encodable, Equatable {
    let currentPassword: String
    let password: String
    let passwordConfirmation: String

    enum CodingKeys: String, CodingKey {
        case currentPassword = "current_password"
        case password
        case passwordConfirmation = "password_confirmation"
    }
}
