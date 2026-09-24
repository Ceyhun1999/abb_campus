import Foundation

protocol AuthService {

    func login(
        email: String,
        password: String,
        role: UserRole
    ) async throws -> LoginResponse

    func me(
        token: String
    ) async throws -> User
}

final class DefaultAuthService: AuthService {

    private let networkService: any NetworkService

    init(
        networkService: any NetworkService = DefaultNetworkService()
    ) {
        self.networkService = networkService
    }

    func login(
        email: String,
        password: String,
        role: UserRole
    ) async throws -> LoginResponse {

        let request = LoginRequest(
            email: email,
            password: password,
            role: role
        )

        let endpoint = AuthEndpoint.login(request)

        return try await networkService.request(endpoint)
    }

    func me(
        token: String
    ) async throws -> User {

        let endpoint = AuthEndpoint.me(
            token: token
        )

        let response: MeResponse = try await networkService.request(
            endpoint
        )

        return response.data
    }
}
