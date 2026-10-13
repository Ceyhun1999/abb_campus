import Foundation

enum StudentEndpoint {
    case grades
    case moduleGrades(moduleId: Int)
    case attendance
    case schedule
    case announcements
}

extension StudentEndpoint: Endpoint {

    var path: String {
        switch self {
        case .grades:
            return "/api/student/grades"

        case .moduleGrades(let moduleId):
            return "/api/student/modules/\(moduleId)/grades"

        case .attendance:
            return "/api/student/attendance"

        case .schedule:
            return "/api/student/schedule"

        case .announcements:
            return "/api/my/announcements"
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
        case .schedule, .announcements:
            return [URLQueryItem(name: "perPage", value: "200")]

        default:
            return nil
        }
    }

    var requiresAuthorization: Bool {
        true
    }
}
