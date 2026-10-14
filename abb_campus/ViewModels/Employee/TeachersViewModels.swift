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

    var isStatusConfirmationPresented = false
    private(set) var state: ViewState<Teacher>
    private(set) var isUpdatingStatus = false
    private(set) var actionErrorMessage: String?

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

    // MARK: - Status

    var statusActionTitle: String {
        state.value?.isActive == true ? "Deaktiv et" : "Aktiv et"
    }

    var statusConfirmationTitle: String {
        state.value?.isActive == true
            ? "Müəllim hesabı deaktiv edilsin? Müəllim tətbiqə daxil ola bilməyəcək."
            : "Müəllim hesabı yenidən aktiv edilsin?"
    }

    func requestStatusChange() {
        isStatusConfirmationPresented = true
    }

    func dismissError() {
        actionErrorMessage = nil
    }

    func toggleStatus() async {
        guard !isUpdatingStatus, let teacher = state.value else {
            return
        }

        actionErrorMessage = nil
        isUpdatingStatus = true

        defer {
            isUpdatingStatus = false
        }

        do {
            try await teacherService.setStatus(userId: teacher.id, isActive: !teacher.isActive)
            state = .loaded(teacher.withStatus(!teacher.isActive))
        } catch {
            actionErrorMessage = error.localizedDescription
        }
    }
}
