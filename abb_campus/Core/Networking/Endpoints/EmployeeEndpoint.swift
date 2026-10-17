import Foundation

enum EmployeeEndpoint {
    case dashboard
    case students(search: String, status: StudentStatusFilter, courseId: Int?)
    case student(id: Int)
    case setUserStatus(userId: Int, isActive: Bool)
    case teachers(search: String, position: TeacherPositionFilter, specialty: String?)
    case teacher(id: Int)
    case groups(search: String, courseId: Int?)
    case group(id: Int)
    case groupStudents(groupId: Int)
    case createGroup(GroupFormRequest)
    case updateGroup(id: Int, GroupFormRequest)
    case courses
    case importStudents(groupId: Int, form: MultipartFormData)
    case announcements
    case createAnnouncement(CreateAnnouncementRequest)
}

extension EmployeeEndpoint: Endpoint {

    private static let pageSize = "200"

    // MARK: - Path

    var path: String {
        switch self {
        case .dashboard:
            return "/api/employee/dashboard"

        case .students:
            return "/api/students"

        case .student(let id):
            return "/api/students/\(id)"

        case .setUserStatus(let userId, _):
            return "/api/users/\(userId)/status"

        case .teachers:
            return "/api/teachers"

        case .teacher(let id):
            return "/api/teachers/\(id)"

        case .groups, .createGroup:
            return "/api/groups"

        case .group(let id), .updateGroup(let id, _):
            return "/api/groups/\(id)"

        case .groupStudents(let groupId):
            return "/api/groups/\(groupId)/students"

        case .courses:
            return "/api/courses"

        case .importStudents(let groupId, _):
            return "/api/groups/\(groupId)/students/import"

        case .announcements, .createAnnouncement:
            return "/api/announcements"
        }
    }

    // MARK: - Method

    var method: HTTPMethod {
        switch self {
        case .setUserStatus, .updateGroup:
            return .patch

        case .createGroup, .importStudents, .createAnnouncement:
            return .post

        default:
            return .get
        }
    }

    // MARK: - Headers

    var headers: [String: String]? {
        switch self {
        case .importStudents:
            return nil

        default:
            return HTTPHeader.json
        }
    }

    // MARK: - Query

    var queryItems: [URLQueryItem]? {
        switch self {
        case .students(let search, let status, let courseId):
            return [
                URLQueryItem(name: "perPage", value: Self.pageSize),
                search.isEmpty ? nil : URLQueryItem(name: "search", value: search),
                status.queryValue.map { URLQueryItem(name: "status", value: $0) },
                courseId.map { URLQueryItem(name: "courseId", value: String($0)) }
            ].compactMap { $0 }

        case .teachers(let search, let position, let specialty):
            return [
                URLQueryItem(name: "perPage", value: Self.pageSize),
                search.isEmpty ? nil : URLQueryItem(name: "search", value: search),
                position.queryValue.map { URLQueryItem(name: "position", value: $0) },
                specialty.map { URLQueryItem(name: "specialty", value: $0) }
            ].compactMap { $0 }

        case .groups(let search, let courseId):
            return [
                URLQueryItem(name: "perPage", value: Self.pageSize),
                search.isEmpty ? nil : URLQueryItem(name: "search", value: search),
                courseId.map { URLQueryItem(name: "courseId", value: String($0)) }
            ].compactMap { $0 }

        case .groupStudents, .courses, .announcements:
            return [URLQueryItem(name: "perPage", value: Self.pageSize)]

        default:
            return nil
        }
    }

    // MARK: - Body

    var httpBody: (any Encodable)? {
        switch self {
        case .setUserStatus(_, let isActive):
            return ["isActive": isActive]

        case .createGroup(let request), .updateGroup(_, let request):
            return request

        case .createAnnouncement(let request):
            return request

        default:
            return nil
        }
    }

    var multipartForm: MultipartFormData? {
        if case .importStudents(_, let form) = self {
            return form
        }

        return nil
    }

    // MARK: - Authorization

    var requiresAuthorization: Bool {
        true
    }
}
