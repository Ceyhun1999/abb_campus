import Foundation

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

extension ScheduleSection {

    /// Lessons of one period grouped by day: upcoming days in order, past days newest first.
    static func sections(from lessons: [ScheduleLesson], period: SchedulePeriod, today: Date) -> [ScheduleSection] {
        let todayString = DateFormatting.apiString(from: today)
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
}
