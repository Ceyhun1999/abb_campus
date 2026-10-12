import Foundation

protocol SecureStorage {
    func save(_ data: Data, for account: String) throws
    func read(for account: String) throws -> Data?
    func delete(for account: String) throws
}
