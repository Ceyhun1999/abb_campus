import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(
        statusCode: Int,
        message: String?
    )
    case decodingError
    case encodingError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL düzgün deyil."

        case .invalidResponse:
            return "Server cavabı düzgün deyil."

        case .serverError(let statusCode, let message):
            return message ?? "Server xətası: \(statusCode)"

        case .decodingError:
            return "Məlumat oxunarkən xəta baş verdi."

        case .encodingError:
            return "Məlumat hazırlanarkən xəta baş verdi."

        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
