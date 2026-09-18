import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case encodingError(Error)
    case decodingError(Error)
    case serverError(
        statusCode: Int,
        response: APIErrorResponse?
    )
    case unknown(Error)
}

// MARK: - LocalizedError

extension NetworkError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL düzgün deyil."

        case .invalidResponse:
            return "Serverdən düzgün cavab alınmadı."

        case .encodingError:
            return "Məlumat göndərilmək üçün hazırlana bilmədi."

        case .decodingError:
            return "Server cavabı oxuna bilmədi."

        case .serverError(_, let response):
            return response?.firstErrorMessage
                ?? "Server xətası baş verdi."

        case .unknown:
            return "Naməlum xəta baş verdi."
        }
    }
}
