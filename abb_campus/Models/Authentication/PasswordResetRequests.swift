import Foundation

struct ForgotPasswordRequest: Encodable {
    let email: String
    let role: UserRole
}

struct VerifyResetCodeRequest: Encodable {
    let email: String
    let role: UserRole
    let code: String
}

struct ResetPasswordRequest: Encodable {
    let email: String
    let role: UserRole
    let code: String
    let password: String
    let passwordConfirmation: String

    enum CodingKeys: String, CodingKey {
        case email
        case role
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
