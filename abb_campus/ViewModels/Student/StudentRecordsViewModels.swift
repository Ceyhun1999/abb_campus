import Foundation
import Observation

@MainActor
@Observable
final class StudentGradesViewModel {

    private(set) var state: ViewState<GradesOverview> = .idle

    private let studentService: any StudentService

    init(studentService: any StudentService) {
        self.studentService = studentService
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            state = .loaded(try await studentService.fetchGradesOverview())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

@MainActor
@Observable
final class ModuleGradesViewModel {

    private(set) var state: ViewState<ModuleGrades> = .idle

    let module: ModuleScore
    private let studentService: any StudentService

    init(module: ModuleScore, studentService: any StudentService) {
        self.module = module
        self.studentService = studentService
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            state = .loaded(try await studentService.fetchModuleGrades(moduleId: module.moduleId))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

@MainActor
@Observable
final class AttendanceViewModel {

    private(set) var state: ViewState<AttendanceSummary> = .idle

    private let studentService: any StudentService

    init(studentService: any StudentService) {
        self.studentService = studentService
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            state = .loaded(try await studentService.fetchAttendance())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

@MainActor
@Observable
final class StudentNotificationsViewModel {

    private(set) var state: ViewState<[Announcement]> = .idle

    private let studentService: any StudentService

    init(studentService: any StudentService) {
        self.studentService = studentService
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            state = .loaded(try await studentService.fetchAnnouncements())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
