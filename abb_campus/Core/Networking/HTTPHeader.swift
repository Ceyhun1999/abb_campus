import Foundation

enum HTTPHeader {
    static let contentType = "Content-Type"
    static let authorization = "Authorization"
    static let accept = "Accept"
}

enum ContentType {
    static let json = "application/json"
}

extension HTTPHeader {

    static var json: [String: String] {
        [
            contentType: ContentType.json,
            accept: ContentType.json
        ]
    }

    static func authorized(token: String) -> [String: String] {
        json.merging([authorization: "Bearer \(token)"]) { _, new in new }
    }
}
