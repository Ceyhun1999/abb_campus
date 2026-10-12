import Foundation

protocol TokenProvider: AnyObject {
    var token: String? { get }
}

/// Holds the current access token so the network layer can authorize
/// requests without depending on `AuthenticationState`.
final class TokenStore: TokenProvider {
    var token: String?
}
