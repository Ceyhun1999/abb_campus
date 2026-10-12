import Foundation

enum DateFormatting {

    private static let apiDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let isoDateTime = ISO8601DateFormatter()

    private static let display: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    /// Accepts `yyyy-MM-dd` or ISO 8601 and returns `dd.MM.yyyy`.
    static func displayDate(from apiValue: String?) -> String? {
        guard let apiValue else {
            return nil
        }

        guard let date = apiDate.date(from: apiValue) ?? isoDateTime.date(from: apiValue) else {
            return nil
        }

        return display.string(from: date)
    }

    static func apiString(from date: Date) -> String {
        apiDate.string(from: date)
    }
}
