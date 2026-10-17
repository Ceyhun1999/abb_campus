import Foundation

/// Loads a group's lessons and exams. Employees, teachers and mentors read the same schedule.
protocol GroupScheduleSource: Sendable {
    func fetchSchedule(groupId: Int) async throws -> [ScheduleLesson]
}

/// Cancels a lesson with a reason, or puts it back. The group's students get a notice.
protocol LessonService: Sendable {
    func cancelLesson(id: Int, reason: CancelReason, note: String?) async throws -> ScheduleLesson
    func restoreLesson(id: Int) async throws -> ScheduleLesson
}

final class DefaultLessonService: LessonService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    func cancelLesson(id: Int, reason: CancelReason, note: String?) async throws -> ScheduleLesson {
        let response: APIResponse<ScheduleLesson> = try await networkService.request(
            LessonEndpoint.cancel(lessonId: id, CancelLessonRequest(reason: reason, note: note))
        )

        return response.data
    }

    func restoreLesson(id: Int) async throws -> ScheduleLesson {
        let response: APIResponse<ScheduleLesson> = try await networkService.request(
            LessonEndpoint.restore(lessonId: id)
        )

        return response.data
    }
}
