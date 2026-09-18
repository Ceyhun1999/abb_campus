import Foundation

final class DefaultNetworkService: NetworkService {

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL = URL(string: "https://campus.jeywastudio.com/api")!,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(
        _ endpoint: Endpoint
    ) async throws -> T {

        let request = try endpoint.makeRequest(baseURL: baseURL)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard 200...299 ~= httpResponse.statusCode else {
                let apiError = try? decoder.decode(
                    APIErrorResponse.self,
                    from: data
                )

                throw NetworkError.serverError(
                    statusCode: httpResponse.statusCode,
                    response: apiError
                )
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }

        } catch let error as NetworkError {
            throw error

        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
