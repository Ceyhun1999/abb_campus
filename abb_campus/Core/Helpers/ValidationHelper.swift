import Foundation

enum ValidationHelper {

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
        password.count >= 6
    }
}
