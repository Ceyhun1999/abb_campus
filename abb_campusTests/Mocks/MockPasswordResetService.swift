import Foundation
@testable import abb_campus

final class MockPasswordResetService: PasswordResetService {

    var requestCodeError: Error?
    var verifyCodeError: Error?
    var resetPasswordError: Error?

    private(set) var requestedEmails: [String] = []
    private(set) var verifiedCodes: [String] = []
    private(set) var resetPasswords: [String] = []

    func requestCode(email: String) async throws {
        requestedEmails.append(email)

        if let requestCodeError {
            throw requestCodeError
        }
    }

    func verifyCode(email: String, code: String) async throws {
        verifiedCodes.append(code)

        if let verifyCodeError {
            throw verifyCodeError
        }
    }

    func resetPassword(email: String, code: String, password: String) async throws {
        resetPasswords.append(password)

        if let resetPasswordError {
            throw resetPasswordError
        }
    }
}
