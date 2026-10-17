import Foundation

/// Requests of the teacher and mentor screens.
enum TeachingEndpoint {
    case myGroups
    case mySchedule
    case groupSchedule(groupId: Int)
    case groupStudents(groupId: Int)
    case attendanceSummary(groupId: Int, month: String)
    case assessments(groupId: Int, month: String)
    case scheduleExam(groupId: Int, ExamFormRequest)
    case importAttendance(groupId: Int, form: MultipartFormData)
    case importTaskScores(groupId: Int, form: MultipartFormData)
    case importExamScores(examId: Int, form: MultipartFormData)
}

extension TeachingEndpoint: Endpoint {

    /// Lessons pile up month by month, so lists are loaded whole (the server allows up to 2000).
    private static let allItems = "2000"

    var path: String {
        switch self {
        case .myGroups:
            return "/api/teacher/groups"
        case .mySchedule:
            return "/api/teacher/schedule"
        case .groupSchedule(let groupId):
            return "/api/groups/\(groupId)/schedule"
        case .groupStudents(let groupId):
            return "/api/groups/\(groupId)/students"
        case .attendanceSummary(let groupId, _):
            return "/api/groups/\(groupId)/attendance/summary"
        case .assessments(let groupId, _):
            return "/api/groups/\(groupId)/assessments"
        case .scheduleExam(let groupId, _):
            return "/api/groups/\(groupId)/exams"
        case .importAttendance(let groupId, _):
            return "/api/groups/\(groupId)/attendance/import"
        case .importTaskScores(let groupId, _):
            return "/api/groups/\(groupId)/tasks/import"
        case .importExamScores(let examId, _):
            return "/api/exams/\(examId)/scores/import"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .scheduleExam, .importAttendance, .importTaskScores, .importExamScores:
            return .post
        default:
            return .get
        }
    }

    var headers: [String: String]? {
        multipartForm == nil ? HTTPHeader.json : nil
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .myGroups, .mySchedule, .groupSchedule, .groupStudents:
            return [URLQueryItem(name: "perPage", value: Self.allItems)]
        case .attendanceSummary(_, let month), .assessments(_, let month):
            return [URLQueryItem(name: "month", value: month)]
        default:
            return nil
        }
    }

    var httpBody: (any Encodable)? {
        if case .scheduleExam(_, let request) = self {
            return request
        }

        return nil
    }

    var multipartForm: MultipartFormData? {
        switch self {
        case .importAttendance(_, let form), .importTaskScores(_, let form), .importExamScores(_, let form):
            return form
        default:
            return nil
        }
    }

    var requiresAuthorization: Bool {
        true
    }
}

// MARK: - Lessons

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
