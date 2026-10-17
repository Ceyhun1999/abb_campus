import Foundation
import Observation

@MainActor
@Observable
final class StudentsListViewModel {

    var searchText = ""
    var statusFilter: StudentStatusFilter = .all {
        didSet {
            if statusFilter != oldValue {
                list.showLoading()
            }
        }
    }
    var courseFilterId: Int? {
        didSet {
            if courseFilterId != oldValue {
                list.showLoading()
            }
        }
    }
    private(set) var courses: [Course] = []
    private let list = PagedList<DirectoryStudent>()
    private(set) var isRefreshing = false
    private var loadedQuery: String?

    private let studentService: any StudentDirectoryService
    private let groupService: any GroupService

    init(studentService: any StudentDirectoryService, groupService: any GroupService) {
        self.studentService = studentService
        self.groupService = groupService
    }

    // MARK: - Paging

    var state: ViewState<[DirectoryStudent]> {
        list.state
    }

    var isLoadingMore: Bool {
        list.isLoadingMore
    }

    func loadMoreIfNeeded(_ item: DirectoryStudent) async {
        await list.loadMore(after: item)
    }

    // MARK: - Query

    var query: String {
        "\(statusFilter.rawValue)|\(courseFilterId.map(String.init) ?? "")|\(trimmedSearch)"
    }

    var courseFilterName: String? {
        courses.first { $0.id == courseFilterId }?.name
    }

    func loadCourses() async {
        guard courses.isEmpty else {
            return
        }

        courses = (try? await groupService.fetchCourses()) ?? []
    }

    var emptyMessage: String {
        trimmedSearch.isEmpty
            ? "Bu filtrə uyğun tələbə yoxdur."
            : "\"\(trimmedSearch)\" üzrə nəticə tapılmadı."
    }

    // MARK: - Search

    func queryChanged() async {
        if state.value != nil && query != loadedQuery {
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

    func load() async {
        let requestedQuery = query
        let search = trimmedSearch
        let status = statusFilter
        let courseId = courseFilterId
        let service = studentService

        let loaded = await list.load { page in
            try await service.fetchStudents(search: search, status: status, courseId: courseId, page: page)
        }

        if loaded {
            loadedQuery = requestedQuery
        }
    }

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
