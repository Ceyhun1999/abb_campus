import Foundation
@testable import abb_campus

final class MockStudentService: StudentService {

    // MARK: - Results

    var gradesResult: Result<GradesOverview, Error> = .success(
        GradesOverview(
            modules: [ModuleScore(moduleId: 1, moduleName: "Swift əsasları", totalScore: 86, maxScore: 100)],
            averageScore: 86,
            overallScore: 86
        )
    )
    var moduleGradesResult: Result<ModuleGrades, Error> = .success(
        ModuleGrades(
            module: .init(id: 1, name: "Swift əsasları"),
            grades: [.init(category: "Homework", score: 28, maxScore: 35)],
            totalScore: 28,
            maxScore: 35
        )
    )
    var attendanceResult: Result<AttendanceSummary, Error> = .success(
        AttendanceSummary(records: [], totalDays: 13, presentDays: 10, attendancePercentage: 76.92)
    )
    var scheduleResult: Result<[ScheduleLesson], Error> = .success([])
    var announcementsResult: Result<[Announcement], Error> = .success([.stub()])

    private(set) var requestedModuleIds: [Int] = []

    // MARK: - StudentService

    func fetchGradesOverview() async throws -> GradesOverview {
        try gradesResult.get()
    }

    func fetchModuleGrades(moduleId: Int) async throws -> ModuleGrades {
        requestedModuleIds.append(moduleId)
        return try moduleGradesResult.get()
    }

    func fetchAttendance() async throws -> AttendanceSummary {
        try attendanceResult.get()
    }

    func fetchSchedule() async throws -> [ScheduleLesson] {
        try scheduleResult.get()
    }

    func fetchAnnouncements() async throws -> [Announcement] {
        try announcementsResult.get()
    }
}

extension ScheduleLesson {

    static func stub(id: Int, date: String, startsAt: String = "19:00") -> ScheduleLesson {
        ScheduleLesson(
            id: id,
            title: "Lesson \(id)",
            date: date,
            startsAt: startsAt,
            endsAt: "21:00",
            room: "402",
            description: nil
        )
    }
}
