import Foundation
import Observation

struct StudentDashboard: Equatable {
    let nextLesson: ScheduleLesson?
    let averageScore: Double
    let attendancePercentage: Double
    let recentAnnouncements: [Announcement]
}

@MainActor
@Observable
final class StudentHomeViewModel {

    private(set) var state: ViewState<StudentDashboard> = .idle

    private let authenticationState: AuthenticationState
    private let studentService: any StudentService
    private let today: () -> Date

    init(
        authenticationState: AuthenticationState,
        studentService: any StudentService,
        today: @escaping () -> Date = Date.init
    ) {
        self.authenticationState = authenticationState
        self.studentService = studentService
        self.today = today
    }

    var greeting: String {
        guard let firstName = authenticationState.currentUser?.firstName,
              !firstName.isEmpty else {
            return "Salam!"
        }

        return "Salam, \(firstName)!"
    }

    var subtitle: String {
        "Uğurlu bir gün arzulayırıq!"
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            async let grades = studentService.fetchGradesOverview()
            async let attendance = studentService.fetchAttendance()
            async let schedule = studentService.fetchSchedule()
            async let announcements = studentService.fetchAnnouncements()

            state = .loaded(StudentDashboard(
                nextLesson: nextLesson(in: try await schedule),
                averageScore: try await grades.averageScore,
                attendancePercentage: try await attendance.attendancePercentage,
                recentAnnouncements: Array(try await announcements.prefix(2))
            ))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    // MARK: - Next Lesson

    private func nextLesson(in lessons: [ScheduleLesson]) -> ScheduleLesson? {
        let todayString = DateFormatting.apiString(from: today())

        return lessons
            .filter { !$0.isCancelled && $0.date >= todayString }
            .min { ($0.date, $0.startsAt) < ($1.date, $1.startsAt) }
    }
}
