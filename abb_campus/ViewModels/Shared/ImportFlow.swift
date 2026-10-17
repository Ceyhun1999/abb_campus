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
    private(set) var state: ViewState<Value> = .idle

    @ObservationIgnored private var latestRequest = LatestRequest()
    @ObservationIgnored private let fetch: (_ month: String) async throws -> Value

    init(today: Date = Date(), fetch: @escaping (_ month: String) async throws -> Value) {
        self.month = MonthCursor(today: today)
        self.fetch = fetch
    }

    func load() async {
        let request = latestRequest.start()

        if state.value == nil {
            state = .loading
        }

        do {
            let value = try await fetch(month.apiValue)

            if latestRequest.isCurrent(request) {
                state = .loaded(value)
            }
        } catch is CancellationError {
        } catch {
            if latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }

    func goBack() async {
        month.goBack()
        state = .loading
        await load()
    }

    func goForward() async {
        guard month.canGoForward else {
            return
        }

        month.goForward()
        state = .loading
        await load()
    }
}
