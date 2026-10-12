import Foundation

final class DefaultNetworkService: NetworkService {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(
        _ endpoint: any Endpoint
    ) async throws -> T {

        do {
            let request = try endpoint.makeRequest()

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }

            guard (200...299).contains(httpResponse.statusCode) else {

                let apiError = try? JSONDecoder().decode(
                    APIErrorResponse.self,
                    from: data
                )

                throw NetworkError.serverError(
                    statusCode: httpResponse.statusCode,
                    message: apiError?.firstErrorMessage
                )
            }

            do {
                return try JSONDecoder().decode(
                    T.self,
                    from: data
                )
            } catch {
                throw NetworkError.decodingError
            }

        } catch let networkError as NetworkError {
            throw networkError

        } catch let urlError as URLError
                    where urlError.code == .notConnectedToInternet ||
                          urlError.code == .networkConnectionLost {
            throw NetworkError.noConnection

        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
