import Foundation
@testable import abb_campus

@MainActor
final class MockTeachingService: TeachingService {

    var groupsResult: Result<[StudyGroup], Error> = .success([.stub()])
    var scheduleResult: Result<[ScheduleLesson], Error> = .success([])
    var studentsResult: Result<[GroupStudent], Error> = .success([])
    var attendanceResult: Result<GroupAttendanceSummary, Error> = .success(
        GroupAttendanceSummary(month: "2026-10", dates: [], students: [])
    )
    var assessmentsResult: Result<[GroupAssessment], Error> = .success([])
    var examResult: Result<ScheduleLesson, Error>?
    var importResult: Result<ImportResult, Error> = .success(ImportResult(imported: 3, skipped: 0, errors: []))

    private(set) var requestedMonths: [String] = []
    private(set) var scheduledExams: [ExamFormRequest] = []
    private(set) var attendanceUploads: [(groupId: Int, fileName: String)] = []
    private(set) var taskUploads: [(groupId: Int, month: String, fileName: String)] = []
    private(set) var examUploads: [(examId: Int, fileName: String)] = []

    func fetchMyGroups() async throws -> [StudyGroup] {
        try groupsResult.get()
    }

    func fetchMySchedule() async throws -> [ScheduleLesson] {
        try scheduleResult.get()
    }

    func fetchSchedule(groupId: Int) async throws -> [ScheduleLesson] {
        try scheduleResult.get()
    }

    func fetchStudents(groupId: Int) async throws -> [GroupStudent] {
        try studentsResult.get()
    }

    func fetchAttendanceSummary(groupId: Int, month: String) async throws -> GroupAttendanceSummary {
        requestedMonths.append(month)
        return try attendanceResult.get()
    }

    func fetchAssessments(groupId: Int, month: String) async throws -> [GroupAssessment] {
        requestedMonths.append(month)
        return try assessmentsResult.get()
    }

    func scheduleExam(groupId: Int, _ request: ExamFormRequest) async throws -> ScheduleLesson {
        scheduledExams.append(request)

        if let examResult {
            return try examResult.get()
        }

        return ScheduleLesson(id: 900, title: request.title, date: request.date, startsAt: request.startsAt,
                              endsAt: request.endsAt, room: request.room, description: nil, kind: .exam)
    }

    func importAttendance(groupId: Int, fileName: String, fileData: Data) async throws -> ImportResult {
        attendanceUploads.append((groupId, fileName))
        return try importResult.get()
    }

    func importTaskScores(groupId: Int, month: String, fileName: String, fileData: Data) async throws -> ImportResult {
        taskUploads.append((groupId, month, fileName))
        return try importResult.get()
    }

    func importExamScores(examId: Int, fileName: String, fileData: Data) async throws -> ImportResult {
        examUploads.append((examId, fileName))
        return try importResult.get()
    }
}

@MainActor
final class MockLessonService: LessonService {

    var error: Error?
    private(set) var cancelled: [(id: Int, reason: CancelReason, note: String?)] = []
    private(set) var restoredIds: [Int] = []

    func cancelLesson(id: Int, reason: CancelReason, note: String?) async throws -> ScheduleLesson {
        if let error {
            throw error
        }

        cancelled.append((id, reason, note))
        return .stub(id: id, isCancelled: true, cancelReason: reason, cancelNote: note)
    }

    func restoreLesson(id: Int) async throws -> ScheduleLesson {
        if let error {
            throw error
        }

        restoredIds.append(id)
        return .stub(id: id)
    }
}
