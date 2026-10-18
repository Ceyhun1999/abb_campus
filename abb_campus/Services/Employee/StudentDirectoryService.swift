import Foundation

protocol StudentDirectoryService {
    func fetchStudents(search: String, courseId: Int?, page: Int) async throws -> Page<DirectoryStudent>
    func fetchStudent(id: Int) async throws -> DirectoryStudent
    /// Removes the student completely: account, group, grades, attendance and scores.
    func deleteStudent(id: Int) async throws
}

final class DefaultStudentDirectoryService: StudentDirectoryService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    func fetchStudents(search: String, courseId: Int?, page: Int) async throws -> Page<DirectoryStudent> {
        let response: PaginatedResponse<DirectoryStudent> = try await networkService.request(
            EmployeeEndpoint.students(search: search, courseId: courseId, page: page)
        )

        return response.page
    }

    func fetchStudent(id: Int) async throws -> DirectoryStudent {
        let response: APIResponse<DirectoryStudent> = try await networkService.request(
            EmployeeEndpoint.student(id: id)
        )

        return response.data
    }

    func deleteStudent(id: Int) async throws {
        let _: MessageResponse = try await networkService.request(
            EmployeeEndpoint.deleteStudent(id: id)
        )
    }
}
