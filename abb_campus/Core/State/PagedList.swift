import Foundation
import Observation

@MainActor
@Observable
final class PagedList<Item: Identifiable> {

    typealias Fetch = (_ page: Int) async throws -> Page<Item>

    private(set) var state: ViewState<[Item]> = .idle
    private(set) var isLoadingMore = false

    private var nextPage: Int?
    private var fetch: Fetch?
    private var generation = 0

    var hasMore: Bool {
        nextPage != nil
    }

    func showLoading() {
        state = .loading
    }

    @discardableResult
    func load(_ fetch: @escaping Fetch) async -> Bool {
        generation += 1
        let currentGeneration = generation

        if state.value == nil {
            state = .loading
        }

        do {
            let page = try await fetch(1)

            guard currentGeneration == generation else {
                return false
            }

            self.fetch = fetch
            state = .loaded(page.items)
            nextPage = page.hasMore ? page.currentPage + 1 : nil
            return true
        } catch is CancellationError {
            return false
        } catch {
            guard currentGeneration == generation else {
                return false
            }

            state = .failed(error.localizedDescription)
            return false
        }
    }

    func loadMore(after item: Item) async {
        guard let items = state.value,
              items.last?.id == item.id,
              let page = nextPage,
              let fetch,
              !isLoadingMore else {
            return
        }

        let currentGeneration = generation
        isLoadingMore = true

        defer {
            isLoadingMore = false
        }

        do {
            let result = try await fetch(page)

            guard currentGeneration == generation, let current = state.value else {
                return
            }

            let knownIDs = Set(current.map(\.id))
            state = .loaded(current + result.items.filter { !knownIDs.contains($0.id) })
            nextPage = result.hasMore ? result.currentPage + 1 : nil
        } catch {
            // The page stays pending and is requested again when the last row reappears.
        }
    }
}
