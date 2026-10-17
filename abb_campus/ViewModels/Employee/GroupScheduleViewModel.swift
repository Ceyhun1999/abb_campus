import Foundation
import Observation

@MainActor
@Observable
final class GroupScheduleViewModel {

    var period: SchedulePeriod = .upcoming
    var isImportPresented = false
    private(set) var state: ViewState<[ScheduleLesson]> = .idle
    private(set) var importViewModel: GroupImportViewModel?

    let group: StudyGroup
    private var latestRequest = LatestRequest()
    private let groupService: any GroupService
    private let today: () -> Date

    init(
        group: StudyGroup,
        groupService: any GroupService,
        today: @escaping () -> Date = Date.init
    ) {
        self.group = group
        self.groupService = groupService
        self.today = today
    }

    // MARK: - Sections

    var sections: [ScheduleSection] {
        ScheduleSection.sections(from: state.value ?? [], period: period, today: today())
    }

    var emptyMessage: String {
        if state.value?.isEmpty == true {
            return "Qrupun cədvəli hələ yoxdur. Excel faylından idxal edin."
        }

        return period == .upcoming ? "Yaxın günlərdə dərs yoxdur." : "Keçmiş dərs yoxdur."
    }

    func load() async {
        let request = latestRequest.start()

        if state.value == nil {
            state = .loading
        }

        do {
            let lessons = try await groupService.fetchSchedule(groupId: group.id)

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

    // MARK: - Import

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
        guard importBlockedReason == nil else {
            return
        }

        importViewModel = GroupImportViewModel(group: group, kind: .schedule, groupService: groupService)
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
