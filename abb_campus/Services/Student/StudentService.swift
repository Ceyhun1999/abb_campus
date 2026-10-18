import Foundation

protocol StudentService: Sendable {
    func fetchAttendance() async throws -> AttendanceSummary
    func fetchSchedule() async throws -> [ScheduleLesson]
    func fetchAnnouncements() async throws -> [Announcement]
    func fetchAssessments() async throws -> [StudentAssessment]
}

final class DefaultStudentService: StudentService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
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

    func fetchAssessments() async throws -> [StudentAssessment] {
        let response: APIResponse<[StudentAssessment]> = try await networkService.request(StudentEndpoint.assessments)
        return response.data
    }
}
