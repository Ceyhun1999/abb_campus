import Foundation
import Observation

/// Opens an import screen and reloads the owner's data when the screen closes.
@MainActor
@Observable
final class ImportFlow {

    var isPresented = false
    private(set) var viewModel: GroupImportViewModel?

    @ObservationIgnored var onFinish: (() async -> Void)?

    func start(_ viewModel: GroupImportViewModel) {
        self.viewModel = viewModel
        isPresented = true
    }

    func presentationChanged(_ isPresented: Bool) async {
        guard !isPresented, viewModel != nil else {
            return
        }

        viewModel = nil
        await onFinish?()
    }
}

// MARK: - Monthly Loader

/// Data of one month (attendance, scores) with month steps. Responses of a month
/// the user has already left are dropped.
@MainActor
@Observable
final class MonthlyLoader<Value> {

    private(set) var month: MonthCursor

    @ObservationIgnored private let content = LoadableValue<Value>(keepsValueOnFailure: false)
    @ObservationIgnored private let fetch: (_ month: String) async throws -> Value

    init(today: Date = Date(), fetch: @escaping (_ month: String) async throws -> Value) {
        self.month = MonthCursor(today: today)
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
