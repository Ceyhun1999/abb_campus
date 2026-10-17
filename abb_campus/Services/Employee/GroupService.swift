import Foundation

protocol GroupService {
    func fetchGroups(search: String, courseId: Int?) async throws -> [StudyGroup]
    func fetchGroupsPage(search: String, courseId: Int?, page: Int) async throws -> Page<StudyGroup>
    func fetchGroup(id: Int) async throws -> StudyGroup
    func fetchStudents(groupId: Int) async throws -> [GroupStudent]
    func fetchCourses() async throws -> [Course]
    func createGroup(_ request: GroupFormRequest) async throws -> StudyGroup
    func updateGroup(id: Int, _ request: GroupFormRequest) async throws -> StudyGroup
    func importStudents(groupId: Int, fileName: String, fileData: Data) async throws -> StudentImportResult
}

final class DefaultGroupService: GroupService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    // MARK: - Groups

    func fetchGroups(search: String, courseId: Int?) async throws -> [StudyGroup] {
        let response: PaginatedResponse<StudyGroup> = try await networkService.request(
            EmployeeEndpoint.groups(search: search, courseId: courseId, page: nil)
        )

        return response.data
    }

    func fetchGroupsPage(search: String, courseId: Int?, page: Int) async throws -> Page<StudyGroup> {
        let response: PaginatedResponse<StudyGroup> = try await networkService.request(
            EmployeeEndpoint.groups(search: search, courseId: courseId, page: page)
        )

        return response.page
    }

    func fetchGroup(id: Int) async throws -> StudyGroup {
        let response: APIResponse<StudyGroup> = try await networkService.request(
            EmployeeEndpoint.group(id: id)
        )

        return response.data
    }

    func fetchStudents(groupId: Int) async throws -> [GroupStudent] {
        let response: PaginatedResponse<GroupStudent> = try await networkService.request(
            EmployeeEndpoint.groupStudents(groupId: groupId)
        )

        return response.data
    }

    // MARK: - Courses

    func fetchCourses() async throws -> [Course] {
        let response: PaginatedResponse<Course> = try await networkService.request(
            EmployeeEndpoint.courses
        )

        return response.data
    }

    // MARK: - Create & Update

    func createGroup(_ request: GroupFormRequest) async throws -> StudyGroup {
        let response: APIResponse<StudyGroup> = try await networkService.request(
            EmployeeEndpoint.createGroup(request)
        )

        return response.data
    }

    func updateGroup(id: Int, _ request: GroupFormRequest) async throws -> StudyGroup {
        let response: APIResponse<StudyGroup> = try await networkService.request(
            EmployeeEndpoint.updateGroup(id: id, request)
        )

        return response.data
    }

    // MARK: - Import

    func importStudents(groupId: Int, fileName: String, fileData: Data) async throws -> StudentImportResult {
        var form = MultipartFormData()
        form.addFile(
            name: "file",
            fileName: fileName,
            mimeType: Self.mimeType(for: fileName),
            data: fileData
        )

        let response: APIResponse<StudentImportResult> = try await networkService.request(
            EmployeeEndpoint.importStudents(groupId: groupId, form: form)
        )

        return response.data
    }

    private static func mimeType(for fileName: String) -> String {
        switch (fileName as NSString).pathExtension.lowercased() {
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "xls":
            return "application/vnd.ms-excel"
        case "csv":
            return "text/csv"
        default:
            return "application/octet-stream"
        }
    }
}
