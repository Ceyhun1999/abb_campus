import Foundation
import Observation

@MainActor
@Observable
final class GroupsListViewModel {

    var searchText = ""
    var courseFilterId: Int? {
        didSet {
            if courseFilterId != oldValue {
                state = .loading
            }
        }
    }
    var isCreateGroupPresented = false
    private(set) var courses: [Course] = []
    private(set) var hasGroups = false
    private(set) var state: ViewState<[StudyGroup]> = .idle
    private(set) var isRefreshing = false
    private var loadedQuery: String?
    private(set) var createGroupViewModel: GroupFormViewModel?

    private let groupService: any GroupService
    private let teacherService: any TeacherService

    init(groupService: any GroupService, teacherService: any TeacherService) {
        self.groupService = groupService
        self.teacherService = teacherService
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
            let groups = try await groupService.fetchGroups(
                search: trimmedSearch,
                courseId: courseFilterId
            )
            state = .loaded(groups)
            hasGroups = !groups.isEmpty
            loadedQuery = requestedQuery
        } catch is CancellationError {
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func showCreateGroup() {
        createGroupViewModel = GroupFormViewModel(
            groupService: groupService,
            teacherService: teacherService
        )
        isCreateGroupPresented = true
    }

    func groupCreated() async {
        isCreateGroupPresented = false
        createGroupViewModel = nil
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
    private(set) var state: ViewState<GroupDetail> = .idle
    private(set) var editViewModel: GroupFormViewModel?

    let group: StudyGroup
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
        if state.value == nil {
            state = .loading
        }

        do {
            async let loadedGroup = groupService.fetchGroup(id: group.id)
            async let loadedStudents = groupService.fetchStudents(groupId: group.id)

            state = .loaded(GroupDetail(
                group: try await loadedGroup,
                students: try await loadedStudents
            ))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func showImport() {
        isImportPresented = true
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
