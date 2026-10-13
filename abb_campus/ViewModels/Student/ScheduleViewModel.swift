import Foundation
import Observation

enum SchedulePeriod: String, CaseIterable, Identifiable {
    case upcoming
    case past

    var id: String { rawValue }

    var title: String {
        switch self {
        case .upcoming: return "Gələcək"
        case .past: return "Keçmiş"
        }
    }
}

struct ScheduleSection: Identifiable, Equatable {
    let date: String
    let title: String
    let lessons: [ScheduleLesson]

    var id: String { date }
}

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

    /// Lessons of the selected period grouped by day:
    /// upcoming days go soonest first, past days go most recent first.
    var sections: [ScheduleSection] {
        guard let lessons = state.value else {
            return []
        }

        let todayString = DateFormatting.apiString(from: today())
        let filtered = lessons.filter { period == .upcoming ? $0.date >= todayString : $0.date < todayString }
        let byDate = Dictionary(grouping: filtered, by: \.date)
        let dates = byDate.keys.sorted(by: period == .upcoming ? (<) : (>))

        return dates.map { date in
            ScheduleSection(
                date: date,
                title: date == todayString ? "Bu gün" : DateFormatting.dayTitle(fromAPI: date),
                lessons: (byDate[date] ?? []).sorted { $0.startsAt < $1.startsAt }
            )
        }
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
