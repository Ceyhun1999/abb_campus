import Foundation

/// A searchable list that reloads when its query changes.
/// The first load starts at once; later changes wait for `SearchDebounce.delay`,
/// so typing quickly sends one request instead of one per letter.
@MainActor
protocol DebouncedSearch: AnyObject {
    var query: String { get }
    var loadedQuery: String? { get }
    var hasResults: Bool { get }
    var isRefreshing: Bool { get set }

    func load() async
}

extension DebouncedSearch {

    func queryChanged() async {
        if hasResults && query != loadedQuery {
            isRefreshing = true

            do {
                try await Task.sleep(for: SearchDebounce.delay)
            } catch {
                return
            }
        }

        defer {
            isRefreshing = false
        }

        await load()
    }
}
