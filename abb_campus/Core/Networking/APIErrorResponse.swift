import Foundation

struct APIErrorResponse: Decodable {
    let success: Bool
    let message: String?
    let errors: [String: [String]]?

    var firstErrorMessage: String? {
        errors?
            .values
            .flatMap { $0 }
            .first ?? message
    }
}
