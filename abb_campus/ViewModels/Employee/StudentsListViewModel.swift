import Foundation
import Observation

@MainActor
@Observable
final class StudentsListViewModel {

    var searchText = ""
    var statusFilter: StudentStatusFilter = .all
    private(set) var state: ViewState<[DirectoryStudent]> = .idle

    private let studentService: any StudentDirectoryService

    init(studentService: any StudentDirectoryService) {
        self.studentService = studentService
    }

    /// Changes whenever the list has to be reloaded.
    var query: String {
        "\(statusFilter.rawValue)|\(trimmedSearch)"
    }

    var emptyMessage: String {
        trimmedSearch.isEmpty
            ? "Bu filtrə uyğun tələbə yoxdur."
            : "\"\(trimmedSearch)\" üzrə nəticə tapılmadı."
    }

    /// Called on every search/filter change; waits briefly so typing
    /// doesn't send a request per keystroke. The first load is immediate.
    func queryChanged() async {
        if state.value != nil {
            do {
                try await Task.sleep(for: SearchDebounce.delay)
            } catch {
                return
            }
        }

        await load()
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            let students = try await studentService.fetchStudents(
                search: trimmedSearch,
                status: statusFilter
            )
            state = .loaded(students)
        } catch is CancellationError {
            // A newer search replaced this request.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
