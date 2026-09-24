import Foundation

protocol NetworkService {
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T
}
