import Foundation

/// Cancelling and restoring lessons: used by employees, teachers and mentors.
enum LessonEndpoint {
    case cancel(lessonId: Int, CancelLessonRequest)
    case restore(lessonId: Int)
}

extension LessonEndpoint: Endpoint {

    var path: String {
        switch self {
        case .cancel(let lessonId, _):
            return "/api/lessons/\(lessonId)/cancel"
        case .restore(let lessonId):
            return "/api/lessons/\(lessonId)/restore"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var headers: [String: String]? {
        HTTPHeader.json
    }

    var httpBody: (any Encodable)? {
        if case .cancel(_, let request) = self {
            return request
        }

        return nil
    }

    var requiresAuthorization: Bool {
        true
    }
}
