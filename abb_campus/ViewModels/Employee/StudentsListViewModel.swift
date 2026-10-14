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
    private(set) var state: ViewState<[DirectoryStudent]> = .idle
    private(set) var isRefreshing = false
    private var loadedQuery: String?

    private let studentService: any StudentDirectoryService

    init(studentService: any StudentDirectoryService) {
        self.studentService = studentService
    }

    // MARK: - Query

    var query: String {
        "\(statusFilter.rawValue)|\(trimmedSearch)"
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
                status: statusFilter
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
