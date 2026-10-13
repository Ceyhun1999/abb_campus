import Foundation

protocol TokenProvider: AnyObject {
    var token: String? { get }
}

// MARK: - Token Store

final class TokenStore: TokenProvider {
    var token: String?
}
