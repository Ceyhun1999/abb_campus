import Foundation

struct APIErrorResponse: Decodable {
    let success: Bool
    let message: String?
    let errors: [String: [String]]?

    var combinedErrorMessage: String? {
        guard let errors, !errors.isEmpty else {
            return message
        }

        var seen = Set<String>()

        return errors
            .sorted { $0.key < $1.key }
            .flatMap(\.value)
            .filter { seen.insert($0).inserted }
            .joined(separator: "\n")
    }
}
