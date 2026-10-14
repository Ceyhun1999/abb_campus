import Foundation
import Observation

@MainActor
@Observable
final class TeachersListViewModel {

    var searchText = ""
    var positionFilter: TeacherPositionFilter = .all {
        didSet {
            if positionFilter != oldValue {
                state = .loading
            }
        }
    }
    var specialtyFilter: String? {
        didSet {
            if specialtyFilter != oldValue {
                state = .loading
            }
        }
    }
    private(set) var specialties: [String] = []
    private(set) var state: ViewState<[Teacher]> = .idle
    private(set) var isRefreshing = false
    private var loadedQuery: String?

    private let teacherService: any TeacherService
    private let groupService: any GroupService

    init(teacherService: any TeacherService, groupService: any GroupService) {
        self.teacherService = teacherService
        self.groupService = groupService
    }

    // MARK: - Query

    var query: String {
        "\(positionFilter.rawValue)|\(specialtyFilter ?? "")|\(trimmedSearch)"
    }

    var hasSpecialtyFilter: Bool {
        specialtyFilter != nil
    }

    var emptyMessage: String {
        trimmedSearch.isEmpty
            ? "Bu filtrə uyğun müəllim yoxdur."
            : "\"\(trimmedSearch)\" üzrə nəticə tapılmadı."
    }

    func loadSpecialties() async {
        guard specialties.isEmpty else {
            return
        }

        specialties = (try? await groupService.fetchCourses().map(\.name)) ?? []
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
            state = .loaded(try await teacherService.fetchTeachers(
                search: trimmedSearch,
                position: positionFilter,
                specialty: specialtyFilter
            ))
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

@MainActor
@Observable
final class TeacherDetailViewModel {

    private(set) var state: ViewState<Teacher>

    private let teacherId: Int
    private let teacherService: any TeacherService

    init(teacher: Teacher, teacherService: any TeacherService) {
        self.teacherId = teacher.id
        self.state = .loaded(teacher)
        self.teacherService = teacherService
    }

    func load() async {
        do {
            state = .loaded(try await teacherService.fetchTeacher(id: teacherId))
        } catch {
            if state.value == nil {
                state = .failed(error.localizedDescription)
            }
        }
    }
}
