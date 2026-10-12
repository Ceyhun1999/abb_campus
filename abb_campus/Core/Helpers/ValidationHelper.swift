import Foundation

enum ValidationHelper {

    static let minimumPasswordLength = 6
    static let minimumNewPasswordLength = 8
    static let resetCodeLength = 6

    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        return email.range(
            of: pattern,
            options: .regularExpression
        ) != nil
    }

    static func isEmpty(_ text: String) -> Bool {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    static func isValidPassword(_ password: String) -> Bool {
        password.count >= minimumPasswordLength
    }

    static func isValidNewPassword(_ password: String) -> Bool {
        password.count >= minimumNewPasswordLength
    }

    static func isValidResetCode(_ code: String) -> Bool {
        code.count == resetCodeLength && code.allSatisfy(\.isNumber)
    }

    /// Returns a user-facing message for the first invalid field, or `nil` when the email is valid.
    static func emailError(_ email: String) -> String? {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedEmail.isEmpty {
            return ValidationMessage.emptyEmail
        }

        if !isValidEmail(trimmedEmail) {
            return ValidationMessage.invalidEmail
        }

        return nil
    }
}
