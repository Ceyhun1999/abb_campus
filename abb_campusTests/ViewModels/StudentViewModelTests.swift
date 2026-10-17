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

    @Test("Home combines grades, attendance, next lesson and announcements")
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
        #expect(dashboard.averageScore == 86)
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
        service.gradesResult = .failure(NetworkError.serverError(
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

    @Test("Grades overview loads and module progress is calculated")
    func grades() async {
        let sut = StudentGradesViewModel(studentService: service)

        await sut.load()

        #expect(sut.state.value?.modules.first?.progress == 0.86)
    }

    @Test("Module grades are requested for the selected module")
    func moduleGrades() async {
        let module = ModuleScore(moduleId: 7, moduleName: "SwiftUI", totalScore: 0, maxScore: 100)
        let sut = ModuleGradesViewModel(module: module, studentService: service)

        await sut.load()

        #expect(service.requestedModuleIds == [7])
        #expect(sut.state.value?.grades.count == 1)
    }

    @Test("Module grades error is shown")
    func moduleGradesFailure() async {
        service.moduleGradesResult = .failure(NetworkError.serverError(statusCode: 403, message: "Bu modul sənin kursuna aid deyil."))
        let module = ModuleScore(moduleId: 9, moduleName: "Java", totalScore: 0, maxScore: 100)
        let sut = ModuleGradesViewModel(module: module, studentService: service)

        await sut.load()

        #expect(sut.state.errorMessage == "Bu modul sənin kursuna aid deyil.")
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
        let sut = StudentNotificationsViewModel(studentService: service)

        await sut.load()

        #expect(sut.state.value?.isEmpty == true)
    }

    private func makeState() throws -> AuthenticationState {
        let state = AuthenticationState(secureStorage: MockSecureStorage(), authService: MockAuthService())
        try state.startSession(user: .stub(), token: "token")
        return state
    }
}
