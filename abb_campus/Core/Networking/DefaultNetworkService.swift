import Foundation

final class DefaultNetworkService: NetworkService {

    private let session: URLSession
    private let tokenProvider: (any TokenProvider)?

    init(
        session: URLSession = .shared,
        tokenProvider: (any TokenProvider)? = nil
    ) {
        self.session = session
        self.tokenProvider = tokenProvider
    }

    // MARK: - Request

    func request<T: Decodable>(
        _ endpoint: any Endpoint
    ) async throws -> T {

        do {
            var request = try endpoint.makeRequest()

            if endpoint.requiresAuthorization {
                guard let token = tokenProvider?.token else {
                    throw NetworkError.unauthorized
                }

                request.setValue(
                    "Bearer \(token)",
                    forHTTPHeaderField: HTTPHeader.authorization
                )
                request.setValue(
                    ContentType.json,
                    forHTTPHeaderField: HTTPHeader.accept
                )
            }

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }

            // The server limits logins, password resets and requests per minute.
            if httpResponse.statusCode == 429 {
                throw NetworkError.tooManyRequests
            }

            guard (200...299).contains(httpResponse.statusCode) else {

                let apiError = try? JSONDecoder().decode(
                    APIErrorResponse.self,
                    from: data
                )

                throw NetworkError.serverError(
                    statusCode: httpResponse.statusCode,
                    message: apiError?.combinedErrorMessage
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

        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CancellationError()

        } catch let urlError as URLError
                    where urlError.code == .notConnectedToInternet ||
                          urlError.code == .networkConnectionLost {
            throw NetworkError.noConnection

        } catch let urlError as URLError
                    where urlError.code == .timedOut ||
                          urlError.code == .cannotConnectToHost ||
                          urlError.code == .cannotFindHost {
            throw NetworkError.serverUnreachable

        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
