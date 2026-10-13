import Foundation

protocol StudentService {
    func fetchGradesOverview() async throws -> GradesOverview
    func fetchModuleGrades(moduleId: Int) async throws -> ModuleGrades
    func fetchAttendance() async throws -> AttendanceSummary
    func fetchSchedule() async throws -> [ScheduleLesson]
    func fetchAnnouncements() async throws -> [Announcement]
}

final class DefaultStudentService: StudentService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    func fetchGradesOverview() async throws -> GradesOverview {
        let response: APIResponse<GradesOverview> = try await networkService.request(StudentEndpoint.grades)
        return response.data
    }

    func fetchModuleGrades(moduleId: Int) async throws -> ModuleGrades {
        let response: APIResponse<ModuleGrades> = try await networkService.request(
            StudentEndpoint.moduleGrades(moduleId: moduleId)
        )
        return response.data
    }

    func fetchAttendance() async throws -> AttendanceSummary {
        let response: APIResponse<AttendanceSummary> = try await networkService.request(StudentEndpoint.attendance)
        return response.data
    }

    func fetchSchedule() async throws -> [ScheduleLesson] {
        let response: PaginatedResponse<ScheduleLesson> = try await networkService.request(StudentEndpoint.schedule)
        return response.data
    }

    func fetchAnnouncements() async throws -> [Announcement] {
        let response: PaginatedResponse<Announcement> = try await networkService.request(StudentEndpoint.announcements)
        return response.data
    }
}
