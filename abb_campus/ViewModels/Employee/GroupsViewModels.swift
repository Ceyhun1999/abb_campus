import Foundation
import Observation

@MainActor
@Observable
final class GroupsListViewModel {

    var searchText = ""
    var isCreateGroupPresented = false
    private(set) var state: ViewState<[StudyGroup]> = .idle

    private let groupService: any GroupService

    init(groupService: any GroupService) {
        self.groupService = groupService
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
            state = .loaded(try await groupService.fetchGroups(
                search: searchText.trimmingCharacters(in: .whitespaces)
            ))
        } catch is CancellationError {
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func showCreateGroup() {
        isCreateGroupPresented = true
    }

    func groupCreated() async {
        isCreateGroupPresented = false
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
    private(set) var state: ViewState<GroupDetail> = .idle

    let group: StudyGroup
    private let groupService: any GroupService

    init(group: StudyGroup, groupService: any GroupService) {
        self.group = group
        self.groupService = groupService
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
}
