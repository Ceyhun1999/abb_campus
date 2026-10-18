import Foundation

/// Loads a group's lessons and exams. Employees, teachers and mentors read the same schedule.
protocol GroupScheduleSource: Sendable {
    func fetchSchedule(groupId: Int) async throws -> [ScheduleLesson]
}
