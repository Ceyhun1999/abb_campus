import Foundation

protocol TeacherService: Sendable {
    func fetchTeachers(search: String, position: TeacherPositionFilter, specialty: String?) async throws -> [Teacher]
    func fetchTeachersPage(search: String, position: TeacherPositionFilter, specialty: String?, page: Int) async throws -> Page<Teacher>
    func fetchTeacher(id: Int) async throws -> Teacher
    func setStatus(userId: Int, isActive: Bool) async throws
}

final class DefaultTeacherService: TeacherService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    func fetchTeachers(search: String, position: TeacherPositionFilter, specialty: String?) async throws -> [Teacher] {
        let response: PaginatedResponse<Teacher> = try await networkService.request(
            EmployeeEndpoint.teachers(search: search, position: position, specialty: specialty, page: nil)
        )

        return response.data
    }

    func fetchTeachersPage(search: String, position: TeacherPositionFilter, specialty: String?, page: Int) async throws -> Page<Teacher> {
        let response: PaginatedResponse<Teacher> = try await networkService.request(
            EmployeeEndpoint.teachers(search: search, position: position, specialty: specialty, page: page)
        )

        return response.page
    }

    func fetchTeacher(id: Int) async throws -> Teacher {
        let response: APIResponse<Teacher> = try await networkService.request(
            EmployeeEndpoint.teacher(id: id)
        )

        return response.data
    }

    func setStatus(userId: Int, isActive: Bool) async throws {
        let _: MessageResponse = try await networkService.request(
            EmployeeEndpoint.setUserStatus(userId: userId, isActive: isActive)
        )
    }
}
