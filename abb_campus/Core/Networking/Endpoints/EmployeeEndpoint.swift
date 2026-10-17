import Foundation

enum EmployeeEndpoint {
    case dashboard
    case students(search: String, status: StudentStatusFilter, courseId: Int?, page: Int)
    case student(id: Int)
    case setUserStatus(userId: Int, isActive: Bool)
    case teachers(search: String, position: TeacherPositionFilter, specialty: String?, page: Int?)
    case teacher(id: Int)
    case groups(search: String, courseId: Int?, page: Int?)
    case group(id: Int)
    case groupStudents(groupId: Int)
    case createGroup(GroupFormRequest)
    case updateGroup(id: Int, GroupFormRequest)
    case courses
    case importStudents(groupId: Int, form: MultipartFormData)
    case groupSchedule(groupId: Int)
    case importSchedule(groupId: Int, form: MultipartFormData)
    case announcements(page: Int)
    case createAnnouncement(AnnouncementFormRequest)
    case updateAnnouncement(id: Int, AnnouncementFormRequest)
    case deleteAnnouncement(id: Int)
}

extension EmployeeEndpoint: Endpoint {

    private static let pageSize = "200"
    /// The schedule is uploaded month by month; one request returns all of a group's lessons.
    private static let schedulePageSize = "2000"
    static let listPageSize = 20

    private static func pageItems(_ page: Int?) -> [URLQueryItem] {
        guard let page else {
            return [URLQueryItem(name: "perPage", value: pageSize)]
        }

        return [
            URLQueryItem(name: "perPage", value: String(listPageSize)),
            URLQueryItem(name: "page", value: String(page))
        ]
    }

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

        case .groupSchedule(let groupId):
            return "/api/groups/\(groupId)/schedule"

        case .importSchedule(let groupId, _):
            return "/api/groups/\(groupId)/schedule/import"

        case .announcements, .createAnnouncement:
            return "/api/announcements"

        case .updateAnnouncement(let id, _), .deleteAnnouncement(let id):
            return "/api/announcements/\(id)"
        }
    }

    // MARK: - Method

    var method: HTTPMethod {
        switch self {
        case .setUserStatus, .updateGroup, .updateAnnouncement:
            return .patch

        case .deleteAnnouncement:
            return .delete

        case .createGroup, .importStudents, .importSchedule, .createAnnouncement:
            return .post

        default:
            return .get
        }
    }

    // MARK: - Headers

    var headers: [String: String]? {
        switch self {
        case .importStudents, .importSchedule:
            return nil

        default:
            return HTTPHeader.json
        }
    }

    // MARK: - Query

    var queryItems: [URLQueryItem]? {
        switch self {
        case .students(let search, let status, let courseId, let page):
            return Self.pageItems(page) + [
                search.isEmpty ? nil : URLQueryItem(name: "search", value: search),
                status.queryValue.map { URLQueryItem(name: "status", value: $0) },
                courseId.map { URLQueryItem(name: "courseId", value: String($0)) }
            ].compactMap { $0 }

        case .teachers(let search, let position, let specialty, let page):
            return Self.pageItems(page) + [
                search.isEmpty ? nil : URLQueryItem(name: "search", value: search),
                position.queryValue.map { URLQueryItem(name: "position", value: $0) },
                specialty.map { URLQueryItem(name: "specialty", value: $0) }
            ].compactMap { $0 }

        case .groups(let search, let courseId, let page):
            return Self.pageItems(page) + [
                search.isEmpty ? nil : URLQueryItem(name: "search", value: search),
                courseId.map { URLQueryItem(name: "courseId", value: String($0)) }
            ].compactMap { $0 }

        case .announcements(let page):
            return Self.pageItems(page)

        case .groupStudents, .courses:
            return [URLQueryItem(name: "perPage", value: Self.pageSize)]

        case .groupSchedule:
            return [URLQueryItem(name: "perPage", value: Self.schedulePageSize)]

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

        case .createAnnouncement(let request), .updateAnnouncement(_, let request):
            return request

        default:
            return nil
        }
    }

    var multipartForm: MultipartFormData? {
        switch self {
        case .importStudents(_, let form), .importSchedule(_, let form):
            return form

        default:
            return nil
        }
    }

    // MARK: - Authorization

    var requiresAuthorization: Bool {
        true
    }
}
