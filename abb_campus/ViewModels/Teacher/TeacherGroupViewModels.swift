import Foundation
import Observation

@MainActor
@Observable
final class TeacherGroupsViewModel {

    private let content = LoadableValue<[StudyGroup]>(keepsValueOnFailure: true)

    private let teachingService: any TeachingService

    init(teachingService: any TeachingService) {
        self.teachingService = teachingService
    }

    var state: ViewState<[StudyGroup]> {
        content.state
    }

    func load() async {
        await content.load {
            try await teachingService.fetchMyGroups()
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

    private let content = LoadableValue<[GroupStudent]>(keepsValueOnFailure: true)

    let group: StudyGroup
    private let teachingService: any TeachingService

    init(group: StudyGroup, teachingService: any TeachingService) {
        self.group = group
        self.teachingService = teachingService
    }

    var routes: [(route: TeacherGroupRoute, icon: String, title: String, subtitle: String)] {
        [
            (.schedule(group), "calendar", "Dərs cədvəli", "Dərsi ləğv et"),
            (.attendance(group), "checklist", "Davamiyyət", "Aylıq Excel yüklə"),
            (.scores(group), "star.circle", "Ballar", "Tapşırıq və imtahan balları"),
            (.exams(group), "graduationcap", "İmtahanlar", "Tarix təyin et, balları yüklə")
        ]
    }

    var state: ViewState<[GroupStudent]> {
        content.state
    }

    func load() async {
        await content.load {
            try await teachingService.fetchStudents(groupId: group.id)
        }
    }
}
