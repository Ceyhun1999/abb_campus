import Foundation

/// Cancelling lessons: used by employees, teachers and mentors.
enum LessonEndpoint {
    case cancel(lessonId: Int, CancelLessonRequest)
}

extension LessonEndpoint: Endpoint {

    var path: String {
        switch self {
        case .cancel(let lessonId, _):
            return "/api/lessons/\(lessonId)/cancel"
        }
    }

    var method: HTTPMethod {
        .post
    }

    var headers: [String: String]? {
        HTTPHeader.json
    }

    var httpBody: (any Encodable)? {
        switch self {
        case .cancel(_, let request):
            return request
        }
    }

    var requiresAuthorization: Bool {
        true
    }
}
