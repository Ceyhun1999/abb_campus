import Foundation

protocol TeacherService {
    func fetchTeachers(search: String, position: TeacherPositionFilter, specialty: String?) async throws -> [Teacher]
    func fetchTeacher(id: Int) async throws -> Teacher
}

final class DefaultTeacherService: TeacherService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    func fetchTeachers(search: String, position: TeacherPositionFilter, specialty: String?) async throws -> [Teacher] {
        let response: PaginatedResponse<Teacher> = try await networkService.request(
            EmployeeEndpoint.teachers(search: search, position: position, specialty: specialty)
        )

        return response.data
    }

    func fetchTeacher(id: Int) async throws -> Teacher {
        let response: APIResponse<Teacher> = try await networkService.request(
            EmployeeEndpoint.teacher(id: id)
        )

        return response.data
    }
}
