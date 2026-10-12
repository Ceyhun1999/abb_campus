import Foundation
@testable import abb_campus

final class MockSecureStorage: SecureStorage {

    var storage: [String: Data] = [:]
    var saveError: Error?

    func save(_ data: Data, for account: String) throws {
        if let saveError {
            throw saveError
        }

        storage[account] = data
    }

    func read(for account: String) throws -> Data? {
        storage[account]
    }

    func delete(for account: String) throws {
        storage[account] = nil
    }

    func storedString(for account: String = "authToken") -> String? {
        storage[account].flatMap { String(data: $0, encoding: .utf8) }
    }
}

final class MockPreferencesStore: PreferencesStore {
    var lastLoginEmail: String?
}
