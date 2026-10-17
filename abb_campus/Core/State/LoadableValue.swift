import Foundation
import Observation

/// The data of one screen and how it loads:
/// - the loading state shows only while there is nothing on screen yet;
/// - a response that is no longer the latest request is dropped;
/// - a cancelled request changes nothing;
/// - a failure replaces the data with an error, or keeps the data already shown
///   when `keepsValueOnFailure` is true (a failed refresh then leaves the screen as it was).
@MainActor
@Observable
final class LoadableValue<Value> {

    private(set) var state: ViewState<Value>

    @ObservationIgnored private var latestRequest = LatestRequest()
    @ObservationIgnored private let keepsValueOnFailure: Bool

    init(_ state: ViewState<Value> = .idle, keepsValueOnFailure: Bool) {
        self.state = state
        self.keepsValueOnFailure = keepsValueOnFailure
    }

    func load(_ fetch: () async throws -> Value) async {
        let request = latestRequest.start()

        if state.value == nil {
            state = .loading
        }

        do {
            let value = try await fetch()

            if latestRequest.isCurrent(request) {
                state = .loaded(value)
            }
        } catch is CancellationError {
        } catch {
            let keepsShownValue = keepsValueOnFailure && state.value != nil

            if !keepsShownValue && latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }

    /// Puts a locally changed value on screen, such as a cancelled lesson.
    func set(_ value: Value) {
        state = .loaded(value)
    }

    /// Shows loading for new data (another month) and drops responses still on their way.
    func showLoading() {
        _ = latestRequest.start()
        state = .loading
    }
}
