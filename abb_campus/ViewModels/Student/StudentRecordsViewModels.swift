import Foundation
import Observation

// MARK: - Grades

@MainActor
@Observable
final class StudentGradesViewModel {

    struct MonthSection: Identifiable, Equatable {
        let month: String
        let title: String
        let items: [StudentAssessment]

        var id: String { month }
    }

    private(set) var state: ViewState<GradesOverview> = .idle
    private(set) var assessments: [StudentAssessment] = []
    private(set) var assessmentsError: String?

    private let studentService: any StudentService

    init(studentService: any StudentService) {
        self.studentService = studentService
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        async let monthly = loadAssessments()

        do {
            state = .loaded(try await studentService.fetchGradesOverview())
        } catch {
            state = .failed(error.localizedDescription)
        }

        await monthly
    }

    // MARK: - Monthly Scores

    /// Task and exam scores grouped by month, newest month first.
    var monthSections: [MonthSection] {
        Dictionary(grouping: assessments, by: \.month)
            .sorted { $0.key > $1.key }
            .map { MonthSection(month: $0.key, title: MonthCursor.title(forAPI: $0.key), items: $0.value) }
    }

    var isEmpty: Bool {
        state.value?.modules.isEmpty == true && assessments.isEmpty
    }

    /// The monthly scores are extra: if they fail, the modules still show.
    private func loadAssessments() async {
        do {
            assessments = try await studentService.fetchAssessments()
            assessmentsError = nil
        } catch is CancellationError {
        } catch {
            assessmentsError = error.localizedDescription
        }
    }
}

// MARK: - Module Grades

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

// MARK: - Attendance

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

// MARK: - Notifications

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
