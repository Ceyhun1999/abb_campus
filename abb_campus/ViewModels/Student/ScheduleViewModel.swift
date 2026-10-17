import Foundation
import Observation

@MainActor
@Observable
final class ScheduleViewModel {

    var period: SchedulePeriod = .upcoming
    private(set) var state: ViewState<[ScheduleLesson]> = .idle

    private let studentService: any StudentService
    private let today: () -> Date

    init(
        studentService: any StudentService,
        today: @escaping () -> Date = Date.init
    ) {
        self.studentService = studentService
        self.today = today
    }

    // MARK: - Sections

    var sections: [ScheduleSection] {
        ScheduleSection.sections(from: state.value ?? [], period: period, today: today())
    }

    var emptyMessage: String {
        period == .upcoming ? "Yaxın günlərdə dərs yoxdur." : "Keçmiş dərs yoxdur."
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            state = .loaded(try await studentService.fetchSchedule())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
