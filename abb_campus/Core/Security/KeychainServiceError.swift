import Foundation

enum KeychainServiceError: LocalizedError {
    case invalidData
    case unexpectedStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "The Keychain value is invalid."

        case .unexpectedStatus(let status):
            return "Keychain operation failed with status: \(status)."
        }
    }
}

