import Foundation

enum EmployeeEndpoint {
    case dashboard
    case students(search: String, status: StudentStatusFilter)
    case student(id: Int)
    case setUserStatus(userId: Int, isActive: Bool)
    case teachers(search: String)
    case teacher(id: Int)
    case groups(search: String)
    case group(id: Int)
    case groupStudents(groupId: Int)
    case createGroup(CreateGroupRequest)
    case courses
    case importStudents(groupId: Int, form: MultipartFormData)
    case announcements
    case createAnnouncement(CreateAnnouncementRequest)
}

extension EmployeeEndpoint: Endpoint {

    private static let pageSize = "200"

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

        case .group(let id):
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

    var method: HTTPMethod {
        switch self {
        case .setUserStatus:
            return .patch

        case .createGroup, .importStudents, .createAnnouncement:
            return .post

        default:
            return .get
        }
    }

    var headers: [String: String]? {
        switch self {
        case .importStudents:
            return nil

        default:
            return HTTPHeader.json
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .students(let search, let status):
            return [
                URLQueryItem(name: "perPage", value: Self.pageSize),
                search.isEmpty ? nil : URLQueryItem(name: "search", value: search),
                status.queryValue.map { URLQueryItem(name: "status", value: $0) }
            ].compactMap { $0 }

        case .teachers(let search), .groups(let search):
            return [
                URLQueryItem(name: "perPage", value: Self.pageSize),
                search.isEmpty ? nil : URLQueryItem(name: "search", value: search)
            ].compactMap { $0 }

        case .groupStudents, .courses, .announcements:
            return [URLQueryItem(name: "perPage", value: Self.pageSize)]

        default:
            return nil
        }
    }

    var httpBody: (any Encodable)? {
        switch self {
        case .setUserStatus(_, let isActive):
            return ["isActive": isActive]

        case .createGroup(let request):
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

    var requiresAuthorization: Bool {
        true
    }
}
