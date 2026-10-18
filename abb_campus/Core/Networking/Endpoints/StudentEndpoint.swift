import Foundation

enum StudentEndpoint {
    case attendance
    case schedule
    case announcements
    case assessments
}

extension StudentEndpoint: Endpoint {

    var path: String {
        switch self {
        case .attendance:
            return "/api/student/attendance"

        case .schedule:
            return "/api/student/schedule"

        case .announcements:
            return "/api/my/announcements"

        case .assessments:
            return "/api/student/assessments"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var headers: [String: String]? {
        HTTPHeader.json
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .schedule:
            // Sorted from the oldest lesson, so a smaller page would cut off the upcoming ones.
            return [URLQueryItem(name: "perPage", value: "2000")]

        case .announcements:
            return [URLQueryItem(name: "perPage", value: "200")]

        default:
            return nil
        }
    }

    var requiresAuthorization: Bool {
        true
    }
}
