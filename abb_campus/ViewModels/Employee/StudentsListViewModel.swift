import Foundation
import Observation

@MainActor
@Observable
final class StudentsListViewModel: DebouncedSearch {

    var searchText = ""
    var courseFilterId: Int? {
        didSet {
            if courseFilterId != oldValue {
                list.showLoading()
            }
        }
    }
    private(set) var courses: [Course] = []
    private let list = PagedList<DirectoryStudent>()
    var isRefreshing = false
    private(set) var loadedQuery: String?

    private let studentService: any StudentDirectoryService
    private let groupService: any GroupService

    init(studentService: any StudentDirectoryService, groupService: any GroupService) {
        self.studentService = studentService
        self.groupService = groupService
    }

    // MARK: - Paging

    var hasResults: Bool {
        state.value != nil
    }

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
        "\(courseFilterId.map(String.init) ?? "")|\(trimmedSearch)"
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
        if !trimmedSearch.isEmpty {
            return "\"\(trimmedSearch)\" üzrə nəticə tapılmadı."
        }

        return courseFilterId == nil
            ? "Hələ tələbə yoxdur. Tələbələri qrupa Excel faylından idxal edin."
            : "Bu kursda tələbə yoxdur."
    }

    // MARK: - Search

    func load() async {
        let requestedQuery = query
        let search = trimmedSearch
        let courseId = courseFilterId
        let service = studentService

        let loaded = await list.load { page in
            try await service.fetchStudents(search: search, courseId: courseId, page: page)
        }

        if loaded {
            loadedQuery = requestedQuery
        }
    }

    /// After returning from a student, so a deleted student leaves the list.
    func reloadIfShown() async {
        guard state.value != nil else {
            return
        }

        await load()
    }

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
