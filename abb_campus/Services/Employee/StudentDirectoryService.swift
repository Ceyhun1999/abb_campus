import Foundation

protocol StudentDirectoryService {
    func fetchStudents(search: String, status: StudentStatusFilter, courseId: Int?) async throws -> [DirectoryStudent]
    func fetchStudent(id: Int) async throws -> DirectoryStudent
    func setStatus(userId: Int, isActive: Bool) async throws
}

final class DefaultStudentDirectoryService: StudentDirectoryService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    func fetchStudents(search: String, status: StudentStatusFilter, courseId: Int?) async throws -> [DirectoryStudent] {
        let response: PaginatedResponse<DirectoryStudent> = try await networkService.request(
            EmployeeEndpoint.students(search: search, status: status, courseId: courseId)
        )

        return response.data
    }

    func fetchStudent(id: Int) async throws -> DirectoryStudent {
        let response: APIResponse<DirectoryStudent> = try await networkService.request(
            EmployeeEndpoint.student(id: id)
        )

        return response.data
    }

    func setStatus(userId: Int, isActive: Bool) async throws {
        let _: MessageResponse = try await networkService.request(
            EmployeeEndpoint.setUserStatus(userId: userId, isActive: isActive)
        )
    }
}
