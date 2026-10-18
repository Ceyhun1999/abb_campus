import Foundation
@testable import abb_campus

@MainActor
final class MockStudentService: StudentService {

    // MARK: - Results

    var attendanceResult: Result<AttendanceSummary, Error> = .success(
        AttendanceSummary(records: [], totalDays: 13, presentDays: 10, attendancePercentage: 76.92)
    )
    var scheduleResult: Result<[ScheduleLesson], Error> = .success([])
    var announcementsResult: Result<[Announcement], Error> = .success([.stub()])
    var assessmentsResult: Result<[StudentAssessment], Error> = .success([])

    // MARK: - StudentService

    func fetchAttendance() async throws -> AttendanceSummary {
        try attendanceResult.get()
    }

    func fetchSchedule() async throws -> [ScheduleLesson] {
        try scheduleResult.get()
    }

    func fetchAnnouncements() async throws -> [Announcement] {
        try announcementsResult.get()
    }

    func fetchAssessments() async throws -> [StudentAssessment] {
        try assessmentsResult.get()
    }
}

extension ScheduleLesson {

    static func stub(
        id: Int = 1,
        date: String = "2026-10-21",
        startsAt: String = "19:00",
        kind: LessonKind = .lesson,
        isCancelled: Bool = false,
        cancelReason: CancelReason? = nil,
        cancelNote: String? = nil,
        groupName: String? = nil
    ) -> ScheduleLesson {
        ScheduleLesson(
            id: id, title: "Lesson \(id)", date: date, startsAt: startsAt, endsAt: "21:00",
            room: "402", description: nil, kind: kind, isCancelled: isCancelled,
            cancelReason: cancelReason, cancelNote: cancelNote, groupName: groupName
        )
    }
}
