import Foundation
import Observation

@MainActor
@Observable
final class TeachersListViewModel {

    var searchText = ""
    private(set) var state: ViewState<[Teacher]> = .idle

    private let teacherService: any TeacherService

    init(teacherService: any TeacherService) {
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
            state = .loaded(try await teacherService.fetchTeachers(
                search: searchText.trimmingCharacters(in: .whitespaces)
            ))
        } catch is CancellationError {
        } catch {
            state = .failed(error.localizedDescription)
        }
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
