import Foundation
import Observation

/// Data of one month (attendance, scores) with month steps. Responses of a month
/// the user has already left are dropped.
@MainActor
@Observable
final class MonthlyLoader<Value> {

    private(set) var month: MonthCursor

    @ObservationIgnored private let content = LoadableValue<Value>(keepsValueOnFailure: false)
    @ObservationIgnored private let fetch: (_ month: String) async throws -> Value

    init(
        today: Date = Date(),
        from start: Date? = nil,
        until end: Date? = nil,
        fetch: @escaping (_ month: String) async throws -> Value
    ) {
        self.month = MonthCursor(today: today, from: start, until: end)
        self.fetch = fetch
    }

    var state: ViewState<Value> {
        content.state
    }

    func load() async {
        let month = month.apiValue
        await content.load {
            try await fetch(month)
        }
    }

    func goBack() async {
        guard month.canGoBack else {
            return
        }

        month.goBack()
        content.showLoading()
        await load()
    }

    func goForward() async {
        guard month.canGoForward else {
            return
        }

        month.goForward()
        content.showLoading()
        await load()
    }
}
