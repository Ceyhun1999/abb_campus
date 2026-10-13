import Foundation
import Observation

@MainActor
@Observable
final class GroupsListViewModel {

    var searchText = ""
    var isCreateGroupPresented = false
    private(set) var state: ViewState<[StudyGroup]> = .idle
    private(set) var createGroupViewModel: GroupFormViewModel?

    private let groupService: any GroupService
    private let teacherService: any TeacherService

    init(groupService: any GroupService, teacherService: any TeacherService) {
        self.groupService = groupService
        self.teacherService = teacherService
    }

    // MARK: - Search

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
            state = .loaded(try await groupService.fetchGroups(
                search: searchText.trimmingCharacters(in: .whitespaces)
            ))
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
