import Foundation
import Observation

@MainActor
@Observable
final class GroupsListViewModel: DebouncedSearch {

    var searchText = ""
    var courseFilterId: Int? {
        didSet {
            if courseFilterId != oldValue {
                list.showLoading()
            }
        }
    }
    var isCreateGroupPresented = false
    private(set) var courses: [Course] = []
    private(set) var hasGroups = false
    private let list = PagedList<StudyGroup>()
    var isRefreshing = false
    private(set) var loadedQuery: String?
    private(set) var createGroupViewModel: GroupFormViewModel?
    var isCreatedGroupPresented = false
    private(set) var createdGroupViewModel: GroupDetailViewModel?
    private var pendingCreatedGroup: StudyGroup?

    private let groupService: any GroupService
    private let teacherService: any TeacherService

    init(groupService: any GroupService, teacherService: any TeacherService) {
        self.groupService = groupService
        self.teacherService = teacherService
    }

    // MARK: - Paging

    var hasResults: Bool {
        state.value != nil
    }

    var state: ViewState<[StudyGroup]> {
        list.state
    }

    var isLoadingMore: Bool {
        list.isLoadingMore
    }

    func loadMoreIfNeeded(_ item: StudyGroup) async {
        await list.loadMore(after: item)
    }

    // MARK: - Search

    var query: String {
        "\(courseFilterId.map(String.init) ?? "")|\(trimmedSearch)"
    }

    var isSearchEnabled: Bool {
        hasGroups || !trimmedSearch.isEmpty
    }

    var isCourseFilterEnabled: Bool {
        courseFilterId != nil || state.value?.isEmpty == false
    }

    var courseFilterName: String? {
        courses.first { $0.id == courseFilterId }?.name
    }

    var emptyMessage: String {
        courseFilterId == nil && trimmedSearch.isEmpty
            ? "Yeni qrup yaratmaq üçün + düyməsinə toxunun."
            : "Bu filtrə uyğun qrup yoxdur."
    }

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    func loadCourses() async {
        guard courses.isEmpty else {
            return
        }

        courses = (try? await groupService.fetchCourses()) ?? []
    }

    func load() async {
        let requestedQuery = query
        let search = trimmedSearch
        let courseId = courseFilterId
        let service = groupService

        let loaded = await list.load { page in
            try await service.fetchGroupsPage(search: search, courseId: courseId, page: page)
        }

        if loaded {
            hasGroups = state.value?.isEmpty == false
            loadedQuery = requestedQuery
        }
    }

    func showCreateGroup() {
        createGroupViewModel = GroupFormViewModel(
            groupService: groupService,
            teacherService: teacherService
        )
        isCreateGroupPresented = true
    }

    func groupCreated(_ group: StudyGroup) {
        pendingCreatedGroup = group
        isCreateGroupPresented = false
        createGroupViewModel = nil
    }

    func createSheetDismissed() async {
        guard let group = pendingCreatedGroup else {
            return
        }

        pendingCreatedGroup = nil
        searchText = ""
        courseFilterId = nil
        createdGroupViewModel = GroupDetailViewModel(
            group: group,
            groupService: groupService,
            teacherService: teacherService
        )
        isCreatedGroupPresented = true
        await load()
    }
}

struct GroupDetail: Equatable {
    let group: StudyGroup
    let students: [GroupStudent]
}

@MainActor
@Observable
final class GroupDetailViewModel {

    var isImportPresented = false
    var isEditPresented = false
    var isSchedulePresented = false
    private(set) var state: ViewState<GroupDetail> = .idle
    private(set) var editViewModel: GroupFormViewModel?
    private(set) var scheduleViewModel: GroupScheduleViewModel?

    let group: StudyGroup
    private var latestRequest = LatestRequest()
    private let groupService: any GroupService
    private let teacherService: any TeacherService

    init(group: StudyGroup, groupService: any GroupService, teacherService: any TeacherService) {
        self.group = group
        self.groupService = groupService
        self.teacherService = teacherService
    }

    var title: String {
        state.value?.group.name ?? group.name
    }

    func load() async {
        let request = latestRequest.start()

        if state.value == nil {
            state = .loading
        }

        do {
            async let loadedGroup = groupService.fetchGroup(id: group.id)
            async let loadedStudents = groupService.fetchStudents(groupId: group.id)

            let detail = GroupDetail(
                group: try await loadedGroup,
                students: try await loadedStudents
            )

            if latestRequest.isCurrent(request) {
                state = .loaded(detail)
            }
        } catch is CancellationError {
        } catch {
            if latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }

    func showImport() {
        isImportPresented = true
    }

    // MARK: - Schedule

    func showSchedule() {
        scheduleViewModel = GroupScheduleViewModel(
            group: state.value?.group ?? group,
            groupService: groupService
        )
        isSchedulePresented = true
    }

    /// Reloads the students after returning from the import screen.
    func importPresentationChanged(_ isPresented: Bool) async {
        guard !isPresented else {
            return
        }

        await load()
    }

    // MARK: - Edit

    func showEdit() {
        editViewModel = GroupFormViewModel(
            group: state.value?.group ?? group,
            groupService: groupService,
            teacherService: teacherService
        )
        isEditPresented = true
    }

    func groupSaved() async {
        isEditPresented = false
        editViewModel = nil
        await load()
    }
}
