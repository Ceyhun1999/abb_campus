import Foundation

protocol NetworkService {
    func request<T: Decodable>(
        _ endpoint: Endpoint
    ) async throws -> T
}
