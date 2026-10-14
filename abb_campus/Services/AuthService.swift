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

    func logout(
        token: String
    ) async throws

    func changePassword(
        token: String,
        request: ChangePasswordRequest
    ) async throws
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

    func logout(
        token: String
    ) async throws {

        let endpoint = AuthEndpoint.logout(
            token: token
        )

        let _: MessageResponse = try await networkService.request(
            endpoint
        )
    }

    func changePassword(
        token: String,
        request: ChangePasswordRequest
    ) async throws {

        let endpoint = AuthEndpoint.changePassword(
            token: token,
            request
        )

        let _: MessageResponse = try await networkService.request(
            endpoint
        )
    }
}
