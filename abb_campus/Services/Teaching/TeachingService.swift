import Foundation

/// Data and uploads of the teacher and mentor screens.
protocol TeachingService: GroupScheduleSource {
    func fetchMyGroups() async throws -> [StudyGroup]
    func fetchMySchedule() async throws -> [ScheduleLesson]
    func fetchStudents(groupId: Int) async throws -> [GroupStudent]
    func fetchAttendanceSummary(groupId: Int, month: String) async throws -> GroupAttendanceSummary
    func fetchAssessments(groupId: Int, month: String) async throws -> [GroupAssessment]
    func scheduleExam(groupId: Int, _ request: ExamFormRequest) async throws -> ScheduleLesson
    func importAttendance(groupId: Int, fileName: String, fileData: Data) async throws -> ImportResult
    func importTaskScores(groupId: Int, month: String, fileName: String, fileData: Data) async throws -> ImportResult
    func importExamScores(examId: Int, fileName: String, fileData: Data) async throws -> ImportResult
}

final class DefaultTeachingService: TeachingService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    // MARK: - Groups

    func fetchMyGroups() async throws -> [StudyGroup] {
        let response: PaginatedResponse<StudyGroup> = try await networkService.request(TeachingEndpoint.myGroups)
        return response.data
    }

    func fetchStudents(groupId: Int) async throws -> [GroupStudent] {
        let response: PaginatedResponse<GroupStudent> = try await networkService.request(
            TeachingEndpoint.groupStudents(groupId: groupId)
        )
        return response.data
    }

    // MARK: - Schedule

    func fetchMySchedule() async throws -> [ScheduleLesson] {
        let response: PaginatedResponse<ScheduleLesson> = try await networkService.request(TeachingEndpoint.mySchedule)
        return response.data
    }

    func fetchSchedule(groupId: Int) async throws -> [ScheduleLesson] {
        let response: PaginatedResponse<ScheduleLesson> = try await networkService.request(
            TeachingEndpoint.groupSchedule(groupId: groupId)
        )
        return response.data
    }

    func scheduleExam(groupId: Int, _ request: ExamFormRequest) async throws -> ScheduleLesson {
        let response: APIResponse<ScheduleLesson> = try await networkService.request(
            TeachingEndpoint.scheduleExam(groupId: groupId, request)
        )
        return response.data
    }

    // MARK: - Monthly Results

    func fetchAttendanceSummary(groupId: Int, month: String) async throws -> GroupAttendanceSummary {
        let response: APIResponse<GroupAttendanceSummary> = try await networkService.request(
            TeachingEndpoint.attendanceSummary(groupId: groupId, month: month)
        )
        return response.data
    }

    func fetchAssessments(groupId: Int, month: String) async throws -> [GroupAssessment] {
        let response: APIResponse<[GroupAssessment]> = try await networkService.request(
            TeachingEndpoint.assessments(groupId: groupId, month: month)
        )
        return response.data
    }

    // MARK: - Imports

    func importAttendance(groupId: Int, fileName: String, fileData: Data) async throws -> ImportResult {
        let response: APIResponse<ImportResult> = try await networkService.request(
            TeachingEndpoint.importAttendance(groupId: groupId, form: .spreadsheet(fileName: fileName, data: fileData))
        )
        return response.data
    }

    func importTaskScores(groupId: Int, month: String, fileName: String, fileData: Data) async throws -> ImportResult {
        let form = MultipartFormData.spreadsheet(fileName: fileName, data: fileData, fields: ["month": month])
        let response: APIResponse<ImportResult> = try await networkService.request(
            TeachingEndpoint.importTaskScores(groupId: groupId, form: form)
        )
        return response.data
    }

    func importExamScores(examId: Int, fileName: String, fileData: Data) async throws -> ImportResult {
        let response: APIResponse<ImportResult> = try await networkService.request(
            TeachingEndpoint.importExamScores(examId: examId, form: .spreadsheet(fileName: fileName, data: fileData))
        )
        return response.data
    }
}
