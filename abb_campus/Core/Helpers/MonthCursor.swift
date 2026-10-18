import Foundation

/// The month shown on a monthly screen (attendance, scores), with steps back and forward.
/// It never moves past the current month: results are uploaded for months that have started.
struct MonthCursor: Equatable {

    private static let names = [
        "Yanvar", "Fevral", "Mart", "Aprel", "May", "İyun",
        "İyul", "Avqust", "Sentyabr", "Oktyabr", "Noyabr", "Dekabr"
    ]

    private(set) var year: Int
    private(set) var month: Int
    private let latest: (year: Int, month: Int)

    init(today: Date = Date(), calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.year, .month], from: today)
        year = parts.year ?? 2026
        month = parts.month ?? 1
        latest = (year, month)
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

    var canGoForward: Bool {
        year < latest.year || (year == latest.year && month < latest.month)
    }

    mutating func goBack() {
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
