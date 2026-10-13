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

    // MARK: - Display

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

    static func date(fromAPI value: String) -> Date? {
        apiDate.date(from: value)
    }

    private static let dayTitle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "az_AZ")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter
    }()

    // MARK: - Day Title

    static func dayTitle(fromAPI value: String) -> String {
        guard let date = apiDate.date(from: value) else {
            return value
        }

        return dayTitle.string(from: date).capitalizedFirstLetter
    }
}

private extension String {

    var capitalizedFirstLetter: String {
        prefix(1).uppercased() + dropFirst()
    }
}
