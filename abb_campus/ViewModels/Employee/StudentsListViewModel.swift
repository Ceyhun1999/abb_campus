import Foundation
import Observation

@MainActor
@Observable
final class StudentsListViewModel {

    var searchText = ""
    var statusFilter: StudentStatusFilter = .all {
        didSet {
            if statusFilter != oldValue {
                state = .loading
            }
        }
    }
    var courseFilterId: Int? {
        didSet {
            if courseFilterId != oldValue {
                state = .loading
            }
        }
    }
    private(set) var courses: [Course] = []
    private(set) var state: ViewState<[DirectoryStudent]> = .idle
    private(set) var isRefreshing = false
    private var loadedQuery: String?

    private let studentService: any StudentDirectoryService
    private let groupService: any GroupService

    init(studentService: any StudentDirectoryService, groupService: any GroupService) {
        self.studentService = studentService
        self.groupService = groupService
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
        if state.value == nil {
            state = .loading
        }

        let requestedQuery = query

        do {
            let students = try await studentService.fetchStudents(
                search: trimmedSearch,
                status: statusFilter,
                courseId: courseFilterId
            )
            state = .loaded(students)
            loadedQuery = requestedQuery
        } catch is CancellationError {
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
