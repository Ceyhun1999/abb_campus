import Foundation
import Observation

struct TeacherOverview: Equatable {
    let groups: [StudyGroup]
    let lessons: [ScheduleLesson]
}

@MainActor
@Observable
final class TeacherHomeViewModel {

    static let nextLessonsLimit = 5

    private(set) var state: ViewState<TeacherOverview> = .idle

    private var latestRequest = LatestRequest()
    private let authenticationState: AuthenticationState
    private let teachingService: any TeachingService
    private let today: () -> Date

    init(
        authenticationState: AuthenticationState,
        teachingService: any TeachingService,
        today: @escaping () -> Date = Date.init
    ) {
        self.authenticationState = authenticationState
        self.teachingService = teachingService
        self.today = today
    }

    var greeting: String {
        guard let firstName = authenticationState.currentUser?.firstName else {
            return "Salam!"
        }

        return "Salam, \(firstName)!"
    }

    // MARK: - Summary

    /// Lessons and exams from today on that are not cancelled, soonest first.
    func nextLessons(_ overview: TeacherOverview) -> [ScheduleLesson] {
        Array(upcoming(overview).prefix(Self.nextLessonsLimit))
    }

    func studentsCount(_ overview: TeacherOverview) -> Int {
        overview.groups.reduce(0) { $0 + ($1.studentsCount ?? 0) }
    }

    func upcomingExamsCount(_ overview: TeacherOverview) -> Int {
        upcoming(overview).filter(\.isExam).count
    }

    func load() async {
        let request = latestRequest.start()

        if state.value == nil {
            state = .loading
        }

        do {
            async let groups = teachingService.fetchMyGroups()
            async let lessons = teachingService.fetchMySchedule()
            let overview = TeacherOverview(groups: try await groups, lessons: try await lessons)

            if latestRequest.isCurrent(request) {
                state = .loaded(overview)
            }
        } catch is CancellationError {
        } catch {
            if state.value == nil && latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }

    private func upcoming(_ overview: TeacherOverview) -> [ScheduleLesson] {
        let todayString = DateFormatting.apiString(from: today())

        return overview.lessons
            .filter { !$0.isCancelled && $0.date >= todayString }
            .sorted { ($0.date, $0.startsAt) < ($1.date, $1.startsAt) }
    }
}
