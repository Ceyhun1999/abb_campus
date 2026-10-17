import Foundation
import Observation

/// All lessons and exams of the teacher's groups.
@MainActor
@Observable
final class TeacherScheduleViewModel {

    var period: SchedulePeriod = .upcoming
    private let content = LoadableValue<[ScheduleLesson]>(keepsValueOnFailure: true)
    let lessonActions: LessonActions

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

    var state: ViewState<[ScheduleLesson]> {
        content.state
    }

    func load() async {
        await content.load {
            try await teachingService.fetchMySchedule()
        }
    }

    private func apply(_ lesson: ScheduleLesson) {
        if let lessons = state.value {
            content.set(lessons.replacing(lesson))
        }
    }
}
