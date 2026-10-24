import Foundation

/// Cancels a lesson with a reason. The group's students get a notice.
protocol LessonService: Sendable {
    func cancelLesson(id: Int, reason: CancelReason, note: String?) async throws -> ScheduleLesson
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
}
