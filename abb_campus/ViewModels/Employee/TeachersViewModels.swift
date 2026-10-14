import Foundation
import Observation

@MainActor
@Observable
final class TeachersListViewModel {

    var searchText = ""
    var positionFilter: TeacherPositionFilter = .all
    var specialtyFilter: String?
    private(set) var specialties: [String] = []
    private(set) var state: ViewState<[Teacher]> = .idle

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
                search: trimmedSearch,
                position: positionFilter,
                specialty: specialtyFilter
            ))
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
