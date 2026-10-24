import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("Student view models")
struct StudentViewModelTests {

    private let today: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 10
        components.day = 13
        components.hour = 12
        return Calendar.current.date(from: components)!
    }()

    private let service = MockStudentService()

    // MARK: - Home

    @Test("Home combines attendance, next lesson and announcements")
    func homeSuccess() async throws {
        service.scheduleResult = .success([
            .stub(id: 1, date: "2026-10-09"),
            .stub(id: 3, date: "2026-10-16"),
            .stub(id: 2, date: "2026-10-14")
        ])
        service.announcementsResult = .success([.stub(id: 1), .stub(id: 2), .stub(id: 3)])
        let sut = StudentHomeViewModel(
            authenticationState: try makeState(),
            studentService: service,
            today: { today }
        )

        await sut.load()

        let dashboard = try #require(sut.state.value)
        #expect(dashboard.nextLesson?.id == 2)
        #expect(dashboard.attendancePercentage == 76.92)
        #expect(dashboard.recentAnnouncements.count == 2)
    }

    @Test("A lesson later today is still the next lesson")
    func homeTodayLesson() async throws {
        service.scheduleResult = .success([
            .stub(id: 5, date: "2026-10-13", startsAt: "19:00"),
            .stub(id: 4, date: "2026-10-13", startsAt: "10:00")
        ])
        let sut = StudentHomeViewModel(authenticationState: try makeState(), studentService: service, today: { today })

        await sut.load()

        #expect(sut.state.value?.nextLesson?.id == 4)
    }

    @Test("A cancelled lesson is skipped as the next lesson")
    func homeSkipsCancelledLesson() async throws {
        service.scheduleResult = .success([
            .stub(id: 4, date: "2026-10-13", startsAt: "10:00", isCancelled: true, cancelReason: .holiday),
            .stub(id: 5, date: "2026-10-13", startsAt: "19:00")
        ])
        let sut = StudentHomeViewModel(authenticationState: try makeState(), studentService: service, today: { today })

        await sut.load()

        #expect(sut.state.value?.nextLesson?.id == 5)
    }

    @Test("No upcoming lessons gives an empty next lesson")
    func homeNoUpcomingLesson() async throws {
        service.scheduleResult = .success([.stub(id: 1, date: "2026-10-01")])
        let sut = StudentHomeViewModel(authenticationState: try makeState(), studentService: service, today: { today })

        await sut.load()

        #expect(sut.state.value != nil)
        #expect(sut.state.value?.nextLesson == nil)
    }

    @Test("Student without a group sees the server message")
    func homeWithoutGroup() async throws {
        service.scheduleResult = .failure(NetworkError.serverError(
            statusCode: 404,
            message: "Sən hələ heç bir qrupa təyin edilməmisən."
        ))
        let sut = StudentHomeViewModel(authenticationState: try makeState(), studentService: service, today: { today })

        await sut.load()

        #expect(sut.state.errorMessage == "Sən hələ heç bir qrupa təyin edilməmisən.")
    }

    // MARK: - Schedule

    @Test("Upcoming lessons are grouped by day, soonest first, today labelled")
    func scheduleUpcoming() async {
        service.scheduleResult = .success([
            .stub(id: 1, date: "2026-10-09"),
            .stub(id: 2, date: "2026-10-15"),
            .stub(id: 3, date: "2026-10-13", startsAt: "19:00"),
            .stub(id: 4, date: "2026-10-13", startsAt: "10:00")
        ])
        let sut = ScheduleViewModel(studentService: service, today: { today })

        await sut.load()

        #expect(sut.sections.map(\.date) == ["2026-10-13", "2026-10-15"])
        #expect(sut.sections.first?.title == "Bu gün")
        #expect(sut.sections.first?.lessons.map(\.id) == [4, 3])
    }

    @Test("Past lessons are shown most recent first")
    func schedulePast() async {
        service.scheduleResult = .success([
            .stub(id: 1, date: "2026-10-05"),
            .stub(id: 2, date: "2026-10-09"),
            .stub(id: 3, date: "2026-10-20")
        ])
        let sut = ScheduleViewModel(studentService: service, today: { today })
        sut.period = .past

        await sut.load()

        #expect(sut.sections.map(\.date) == ["2026-10-09", "2026-10-05"])
        #expect(sut.emptyMessage == "Keçmiş dərs yoxdur.")
    }

    @Test("Schedule error is shown")
    func scheduleFailure() async {
        service.scheduleResult = .failure(NetworkError.noConnection)
        let sut = ScheduleViewModel(studentService: service, today: { today })

        await sut.load()

        #expect(sut.state.errorMessage == "İnternet bağlantısı yoxdur.")
        #expect(sut.sections.isEmpty)
    }

    // MARK: - Grades, attendance, notifications

    @Test("Grades list the teacher's scores by month, newest month first")
    func grades() async {
        service.assessmentsResult = .success([
            StudentAssessment(id: 1, kind: .task, title: "Layout", month: "2026-09", examDate: nil, score: 80, maxScore: 100),
            StudentAssessment(id: 2, kind: .exam, title: "Final", month: "2026-10", examDate: "2026-10-20", score: 91, maxScore: 100),
            StudentAssessment(id: 3, kind: .task, title: "Networking", month: "2026-10", examDate: nil, score: 70, maxScore: 100)
        ])
        let sut = StudentGradesViewModel(studentService: service)

        await sut.load()

        let sections = sut.monthSections(sut.state.value ?? [])
        #expect(sections.map(\.month) == ["2026-10", "2026-09"])
        #expect(sections.first?.items.map(\.id) == [2, 3])
        #expect(sections.first?.title == "Oktyabr 2026")
    }

    @Test("Grades error is shown")
    func gradesFailure() async {
        service.assessmentsResult = .failure(NetworkError.serverError(statusCode: 500, message: "Server xətası"))
        let sut = StudentGradesViewModel(studentService: service)

        await sut.load()

        #expect(sut.state.errorMessage == "Server xətası")
    }

    @Test("Attendance summary loads")
    func attendance() async {
        let sut = AttendanceViewModel(studentService: service)

        await sut.load()

        #expect(sut.state.value?.presentDays == 10)
    }

    @Test("Notifications can be empty")
    func notificationsEmpty() async {
        service.announcementsResult = .success([])
        let sut = NotificationsViewModel(feed: service)

        await sut.load()

        #expect(sut.state.value?.isEmpty == true)
    }

    private func makeState() throws -> AuthenticationState {
        let state = AuthenticationState(secureStorage: MockSecureStorage(), authService: MockAuthService())
        try state.startSession(user: .stub(), token: "token")
        return state
    }
}
