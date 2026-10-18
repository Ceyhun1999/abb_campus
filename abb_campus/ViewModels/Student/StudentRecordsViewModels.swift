import Foundation
import Observation

// MARK: - Grades

/// The scores a teacher has entered for the student (tasks and exams), as a list by month.
@MainActor
@Observable
final class StudentGradesViewModel {

    struct MonthSection: Identifiable, Equatable {
        let month: String
        let title: String
        let items: [StudentAssessment]

        var id: String { month }
    }

    private(set) var state: ViewState<[StudentAssessment]> = .idle

    private let studentService: any StudentService

    init(studentService: any StudentService) {
        self.studentService = studentService
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            state = .loaded(try await studentService.fetchAssessments())
        } catch is CancellationError {
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Newest month first.
    func monthSections(_ assessments: [StudentAssessment]) -> [MonthSection] {
        Dictionary(grouping: assessments, by: \.month)
            .sorted { $0.key > $1.key }
            .map { MonthSection(month: $0.key, title: MonthCursor.title(forAPI: $0.key), items: $0.value) }
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
