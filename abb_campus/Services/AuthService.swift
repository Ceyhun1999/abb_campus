import Foundation

protocol AuthService {
    func login(
        email: String,
        password: String
    ) async throws -> LoginResponse
}

final class DefaultAuthService: AuthService {

    private let networkService: NetworkService
    private let encoder: JSONEncoder

    init(
        networkService: NetworkService,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.networkService = networkService
        self.encoder = encoder
    }

    func login(
        email: String,
        password: String
    ) async throws -> LoginResponse {

        let loginRequest = LoginRequest(
            email: email,
            password: password
        )

        let body: Data

        do {
            body = try encoder.encode(loginRequest)
        } catch {
            throw NetworkError.encodingError(error)
        }

        let endpoint = Endpoint(
            path: "/auth/login",
            method: .post,
            body: body
        )

        return try await networkService.request(endpoint)
    }
}
