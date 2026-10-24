import Foundation
@testable import abb_campus

final class MockPasswordResetService: PasswordResetService {

    var requestCodeError: Error?
    var verifyCodeError: Error?
    var resetPasswordError: Error?

    private(set) var requestedEmails: [String] = []
    private(set) var roles: [UserRole] = []
    private(set) var verifiedCodes: [String] = []
    private(set) var resetPasswords: [String] = []

    func requestCode(email: String, role: UserRole) async throws {
        requestedEmails.append(email)
        roles.append(role)

        if let requestCodeError {
            throw requestCodeError
        }
    }

    func verifyCode(email: String, role: UserRole, code: String) async throws {
        verifiedCodes.append(code)
        roles.append(role)

        if let verifyCodeError {
            throw verifyCodeError
        }
    }

    func resetPassword(email: String, role: UserRole, code: String, password: String) async throws {
        resetPasswords.append(password)
        roles.append(role)

        if let resetPasswordError {
            throw resetPasswordError
        }
    }
}
