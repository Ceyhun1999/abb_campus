import Foundation
import Observation

@MainActor
@Observable
final class TeachersListViewModel {

    var searchText = ""
    var positionFilter: TeacherPositionFilter = .all {
        didSet {
            if positionFilter != oldValue {
                list.showLoading()
            }
        }
    }
    var specialtyFilter: String? {
        didSet {
            if specialtyFilter != oldValue {
                list.showLoading()
            }
        }
    }
    private(set) var specialties: [String] = []
    private let list = PagedList<Teacher>()
    private(set) var isRefreshing = false
    private var loadedQuery: String?

    private let teacherService: any TeacherService
    private let groupService: any GroupService

    init(teacherService: any TeacherService, groupService: any GroupService) {
        self.teacherService = teacherService
        self.groupService = groupService
    }

    // MARK: - Paging

    var state: ViewState<[Teacher]> {
        list.state
    }

    var isLoadingMore: Bool {
        list.isLoadingMore
    }

    func loadMoreIfNeeded(_ item: Teacher) async {
        await list.loadMore(after: item)
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
        let requestedQuery = query
        let search = trimmedSearch
        let position = positionFilter
        let specialty = specialtyFilter
        let service = teacherService

        let loaded = await list.load { page in
            try await service.fetchTeachersPage(search: search, position: position, specialty: specialty, page: page)
        }

        if loaded {
            loadedQuery = requestedQuery
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

    private var latestRequest = LatestRequest()
    private let teacherId: Int
    private let teacherService: any TeacherService

    init(teacher: Teacher, teacherService: any TeacherService) {
        self.teacherId = teacher.id
        self.state = .loaded(teacher)
        self.teacherService = teacherService
    }

    func load() async {
        let request = latestRequest.start()

        do {
            let teacher = try await teacherService.fetchTeacher(id: teacherId)

            if latestRequest.isCurrent(request) {
                state = .loaded(teacher)
            }
        } catch is CancellationError {
        } catch {
            if state.value == nil && latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }

    // MARK: - Status

    var statusActionTitle: String {
        state.value?.isActive == true ? "Deaktiv et" : "Aktiv et"
    }

    var statusConfirmationTitle: String {
        guard let teacher = state.value, teacher.isActive else {
            return "Müəllim hesabı yenidən aktiv edilsin?"
        }

        let base = "Müəllim hesabı deaktiv edilsin? Müəllim tətbiqə daxil ola bilməyəcək."

        guard let groupsCount = teacher.groupsCount, groupsCount > 0 else {
            return base
        }

        return base + " Bu müəllim \(groupsCount) qrupda müəllim və ya mentordur: qruplarda qalacaq, onu redaktə ilə əvəz edin."
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
            _ = latestRequest.start()
            state = .loaded(teacher.withStatus(!teacher.isActive))
        } catch {
            actionErrorMessage = error.localizedDescription
        }
    }
}
