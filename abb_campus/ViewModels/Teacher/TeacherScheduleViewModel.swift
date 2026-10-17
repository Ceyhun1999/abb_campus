import Foundation
import Observation

/// All lessons and exams of the teacher's groups.
@MainActor
@Observable
final class TeacherScheduleViewModel {

    var period: SchedulePeriod = .upcoming
    private(set) var state: ViewState<[ScheduleLesson]> = .idle
    let lessonActions: LessonActions

    private var latestRequest = LatestRequest()
    private let teachingService: any TeachingService
    private let today: () -> Date

    init(
        teachingService: any TeachingService,
        lessonService: any LessonService,
        today: @escaping () -> Date = Date.init
    ) {
        self.teachingService = teachingService
        self.today = today
        self.lessonActions = LessonActions(lessonService: lessonService, today: today)

        lessonActions.onChange = { [weak self] lesson in
            self?.apply(lesson)
        }
    }

    var sections: [ScheduleSection] {
        ScheduleSection.sections(from: state.value ?? [], period: period, today: today())
    }

    var emptyMessage: String {
        period == .upcoming ? "Yaxın günlərdə dərs yoxdur." : "Keçmiş dərs yoxdur."
    }

    func load() async {
        let request = latestRequest.start()

        if state.value == nil {
            state = .loading
        }

        do {
            let lessons = try await teachingService.fetchMySchedule()

            if latestRequest.isCurrent(request) {
                state = .loaded(lessons)
            }
        } catch is CancellationError {
        } catch {
            if state.value == nil && latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }

    private func apply(_ lesson: ScheduleLesson) {
        if let lessons = state.value {
            state = .loaded(lessons.replacing(lesson))
        }
    }
}
