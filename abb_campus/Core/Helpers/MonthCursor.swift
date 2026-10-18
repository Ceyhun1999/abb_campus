import Foundation

/// The month shown on a monthly screen (attendance, scores), with steps back and forward.
/// It stays within the group's months: not before the month the group starts,
/// not past the month it ends, and not past the current month (results are uploaded
/// for months that have started).
struct MonthCursor: Equatable {

    private typealias Month = (year: Int, month: Int)

    private static let names = [
        "Yanvar", "Fevral", "Mart", "Aprel", "May", "İyun",
        "İyul", "Avqust", "Sentyabr", "Oktyabr", "Noyabr", "Dekabr"
    ]

    private(set) var year: Int
    private(set) var month: Int
    private let earliest: Month
    private let latest: Month

    /// Starts on the latest month allowed: the current one, or the last month of a finished group.
    init(today: Date = Date(), from start: Date? = nil, until end: Date? = nil, calendar: Calendar = .current) {
        var latest = Self.month(of: today, calendar: calendar)

        if let end {
            latest = Self.earlier(latest, Self.month(of: end, calendar: calendar))
        }

        // Without a start date the months go back freely; a group that has not started stays on one month.
        let earliest = start.map { Self.earlier(Self.month(of: $0, calendar: calendar), latest) } ?? (Int.min, 1)

        self.earliest = earliest
        self.latest = latest
        year = latest.year
        month = latest.month
    }

    private static func month(of date: Date, calendar: Calendar) -> Month {
        let parts = calendar.dateComponents([.year, .month], from: date)
        return (parts.year ?? 2026, parts.month ?? 1)
    }

    private static func isBefore(_ lhs: Month, _ rhs: Month) -> Bool {
        lhs.year < rhs.year || (lhs.year == rhs.year && lhs.month < rhs.month)
    }

    private static func earlier(_ lhs: Month, _ rhs: Month) -> Month {
        isBefore(rhs, lhs) ? rhs : lhs
    }

    /// "2026-10" → "Oktyabr 2026"
    static func title(forAPI value: String) -> String {
        let parts = value.split(separator: "-").compactMap { Int($0) }

        guard parts.count == 2, (1...12).contains(parts[1]) else {
            return value
        }

        return "\(names[parts[1] - 1]) \(parts[0])"
    }

    /// "2026-10", as the API expects.
    var apiValue: String {
        String(format: "%04d-%02d", year, month)
    }

    /// "Oktyabr 2026"
    var title: String {
        "\(Self.names[month - 1]) \(year)"
    }

    var canGoBack: Bool {
        Self.isBefore(earliest, (year, month))
    }

    var canGoForward: Bool {
        Self.isBefore((year, month), latest)
    }

    mutating func goBack() {
        guard canGoBack else {
            return
        }

        if month == 1 {
            year -= 1
            month = 12
        } else {
            month -= 1
        }
    }

    mutating func goForward() {
        guard canGoForward else {
            return
        }

        if month == 12 {
            year += 1
            month = 1
        } else {
            month += 1
        }
    }

    static func == (lhs: MonthCursor, rhs: MonthCursor) -> Bool {
        lhs.year == rhs.year && lhs.month == rhs.month
    }
}
