import Foundation
import Observation

@MainActor
@Observable
final class GroupScheduleViewModel {

    var period: SchedulePeriod = .upcoming
    var isImportPresented = false
    private let content = LoadableValue<[ScheduleLesson]>(keepsValueOnFailure: true)
    private(set) var importViewModel: GroupImportViewModel?
    let lessonActions: LessonActions

    let group: StudyGroup
    private let scheduleSource: any GroupScheduleSource
    private let scheduleImporter: (any GroupService)?
    private let today: () -> Date

    /// - Parameter scheduleImporter: lets an employee upload the schedule from Excel; teachers have none.
    init(
        group: StudyGroup,
        scheduleSource: any GroupScheduleSource,
        lessonService: any LessonService,
        scheduleImporter: (any GroupService)? = nil,
        today: @escaping () -> Date = Date.init
    ) {
        self.group = group
        self.scheduleSource = scheduleSource
        self.scheduleImporter = scheduleImporter
        self.today = today
        self.lessonActions = LessonActions(lessonService: lessonService, today: today)

        lessonActions.onChange = { [weak self] lesson in
            self?.apply(lesson)
        }
    }

    // MARK: - Sections

    var sections: [ScheduleSection] {
        ScheduleSection.sections(from: state.value ?? [], period: period, today: today())
    }

    var emptyMessage: String {
        if state.value?.isEmpty == true {
            return canImport
                ? "Qrupun cədvəli hələ yoxdur. Excel faylından idxal edin."
                : "Qrupun cədvəli hələ yoxdur."
        }

        return period == .upcoming ? "Yaxın günlərdə dərs yoxdur." : "Keçmiş dərs yoxdur."
    }

    var state: ViewState<[ScheduleLesson]> {
        content.state
    }

    func load() async {
        await content.load {
            try await scheduleSource.fetchSchedule(groupId: group.id)
        }
    }

    private func apply(_ lesson: ScheduleLesson) {
        if let lessons = state.value {
            content.set(lessons.replacing(lesson))
        }
    }

    // MARK: - Import

    var canImport: Bool {
        scheduleImporter != nil
    }

    /// Why the schedule cannot be imported, or `nil` when it can.
    var importBlockedReason: String? {
        if !group.isActive {
            return "Qrup bitib. Bitmiş qrupa cədvəl idxal etmək olmaz."
        }

        if group.teacher == nil {
            return "Əvvəlcə qrupa müəllim təyin edin. Dərslər qrupun müəllimi ilə yaradılır."
        }

        return nil
    }

    func showImport() {
        guard let scheduleImporter, importBlockedReason == nil else {
            return
        }

        importViewModel = GroupImportViewModel(group: group, kind: .schedule, groupService: scheduleImporter)
        isImportPresented = true
    }

    /// Reloads the schedule after returning from the import screen.
    func importPresentationChanged(_ isPresented: Bool) async {
        guard !isPresented else {
            return
        }

        importViewModel = nil
        await load()
    }
}
