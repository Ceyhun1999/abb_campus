import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("PagedList")
struct PagedListTests {

    struct Row: Identifiable, Equatable {
        let id: Int
    }

    final class Source {
        let total: Int
        let size: Int
        var requestedPages: [Int] = []
        var failNextPage = false
        var delay: Duration?

        init(total: Int, size: Int = 20) {
            self.total = total
            self.size = size
        }

        var lastPage: Int {
            max(Int((Double(total) / Double(size)).rounded(.up)), 1)
        }

        func fetch(_ page: Int) async throws -> Page<Row> {
            requestedPages.append(page)

            if let delay {
                try await Task.sleep(for: delay)
            }

            if failNextPage {
                failNextPage = false
                throw NetworkError.noConnection
            }

            let start = (page - 1) * size
            let items = (start..<min(start + size, total)).map { Row(id: $0 + 1) }
            return Page(items: items, currentPage: page, lastPage: lastPage)
        }
    }

    @Test("The first page is loaded and more pages are known to exist")
    func firstPage() async {
        let source = Source(total: 45)
        let sut = PagedList<Row>()

        await sut.load(source.fetch)

        #expect(sut.state.value?.count == 20)
        #expect(sut.hasMore)
        #expect(source.requestedPages == [1])
    }

    @Test("The next page is loaded only when the last row appears")
    func loadMoreOnLastRow() async throws {
        let source = Source(total: 45)
        let sut = PagedList<Row>()
        await sut.load(source.fetch)

        await sut.loadMore(after: Row(id: 5))
        #expect(source.requestedPages == [1])

        let last = try #require(sut.state.value?.last)
        await sut.loadMore(after: last)

        #expect(sut.state.value?.count == 40)
        #expect(source.requestedPages == [1, 2])
    }

    @Test("Loading stops after the last page")
    func stopsAtLastPage() async throws {
        let source = Source(total: 45)
        let sut = PagedList<Row>()
        await sut.load(source.fetch)

        for _ in 0..<5 {
            let last = try #require(sut.state.value?.last)
            await sut.loadMore(after: last)
        }

        #expect(sut.state.value?.count == 45)
        #expect(sut.hasMore == false)
        #expect(source.requestedPages == [1, 2, 3])
    }

    @Test("A new search drops a slower page from the previous one")
    func staleLoadMoreIsIgnored() async throws {
        let old = Source(total: 45)
        let sut = PagedList<Row>()
        await sut.load(old.fetch)
        let last = try #require(sut.state.value?.last)
        old.delay = .milliseconds(200)

        let slowMore = Task { await sut.loadMore(after: last) }
        try await Task.sleep(for: .milliseconds(50))
        await sut.load(Source(total: 3).fetch)
        await slowMore.value

        #expect(sut.state.value?.map(\.id) == [1, 2, 3])
        #expect(sut.hasMore == false)
    }

    @Test("Rows already shown are not added twice")
    func duplicatesAreSkipped() async throws {
        let sut = PagedList<Row>()
        await sut.load { page in
            page == 1
                ? Page(items: [Row(id: 1), Row(id: 2)], currentPage: 1, lastPage: 2)
                : Page(items: [Row(id: 2), Row(id: 3)], currentPage: 2, lastPage: 2)
        }

        await sut.loadMore(after: Row(id: 2))

        #expect(sut.state.value?.map(\.id) == [1, 2, 3])
    }

    @Test("A failed page keeps the list and is retried")
    func failedPageIsRetried() async throws {
        let source = Source(total: 45)
        let sut = PagedList<Row>()
        await sut.load(source.fetch)
        let last = try #require(sut.state.value?.last)

        source.failNextPage = true
        await sut.loadMore(after: last)
        #expect(sut.state.value?.count == 20)
        #expect(sut.hasMore)

        await sut.loadMore(after: last)
        #expect(sut.state.value?.count == 40)
    }

    @Test("A failing first page shows the error")
    func firstPageError() async {
        let source = Source(total: 45)
        source.failNextPage = true
        let sut = PagedList<Row>()

        await sut.load(source.fetch)

        #expect(sut.state.errorMessage != nil)
    }
}
