import Foundation
import Observation

@MainActor
@Observable
final class TeacherGroupsViewModel {

    private(set) var state: ViewState<[StudyGroup]> = .idle

    private var latestRequest = LatestRequest()
    private let teachingService: any TeachingService

    init(teachingService: any TeachingService) {
        self.teachingService = teachingService
    }

    func load() async {
        let request = latestRequest.start()

        if state.value == nil {
            state = .loading
        }

        do {
            let groups = try await teachingService.fetchMyGroups()

            if latestRequest.isCurrent(request) {
                state = .loaded(groups)
            }
        } catch is CancellationError {
        } catch {
            if state.value == nil && latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }
}

// MARK: - Group Detail

enum TeacherGroupRoute: Hashable {
    case schedule(StudyGroup)
    case attendance(StudyGroup)
    case scores(StudyGroup)
    case exams(StudyGroup)
}

@MainActor
@Observable
final class TeacherGroupDetailViewModel {

    private(set) var state: ViewState<[GroupStudent]> = .idle

    let group: StudyGroup
    private var latestRequest = LatestRequest()
    private let teachingService: any TeachingService

    init(group: StudyGroup, teachingService: any TeachingService) {
        self.group = group
        self.teachingService = teachingService
    }

    var routes: [(route: TeacherGroupRoute, icon: String, title: String, subtitle: String)] {
        [
            (.schedule(group), "calendar", "Dərs cədvəli", "Dərsi ləğv et və ya bərpa et"),
            (.attendance(group), "checklist", "Davamiyyət", "Aylıq Excel yüklə"),
            (.scores(group), "star.circle", "Ballar", "Tapşırıq və imtahan balları"),
            (.exams(group), "graduationcap", "İmtahanlar", "Tarix təyin et, balları yüklə")
        ]
    }

    func load() async {
        let request = latestRequest.start()

        if state.value == nil {
            state = .loading
        }

        do {
            let students = try await teachingService.fetchStudents(groupId: group.id)

            if latestRequest.isCurrent(request) {
                state = .loaded(students)
            }
        } catch is CancellationError {
        } catch {
            if state.value == nil && latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }
}
