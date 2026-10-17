import SwiftUI

struct TeacherTabView: View {

    @Environment(AuthenticationState.self) private var authenticationState
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        TabView {
            NavigationStack {
                TeacherHomeView(
                    viewModel: TeacherHomeViewModel(
                        authenticationState: authenticationState,
                        teachingService: dependencies.teachingService
                    )
                )
                .teacherDestinations()
            }
            .tabItem {
                Label("Ana səhifə", systemImage: "house.fill")
            }

            NavigationStack {
                TeacherGroupsView(
                    viewModel: TeacherGroupsViewModel(teachingService: dependencies.teachingService)
                )
                .teacherDestinations()
            }
            .tabItem {
                Label("Qruplar", systemImage: "square.grid.2x2.fill")
            }

            NavigationStack {
                TeacherScheduleView(
                    viewModel: TeacherScheduleViewModel(
                        teachingService: dependencies.teachingService,
                        lessonService: dependencies.lessonService
                    )
                )
            }
            .tabItem {
                Label("Cədvəl", systemImage: "calendar")
            }

            ProfileView(
                viewModel: ProfileViewModel(authenticationState: authenticationState)
            )
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
        }
    }
}

// MARK: - Destinations

private struct TeacherDestinations: ViewModifier {

    @Environment(\.dependencies) private var dependencies

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: StudyGroup.self) { group in
                TeacherGroupDetailView(
                    viewModel: TeacherGroupDetailViewModel(group: group, teachingService: dependencies.teachingService)
                )
            }
            .navigationDestination(for: TeacherGroupRoute.self) { route in
                switch route {
                case .schedule(let group):
                    GroupScheduleView(
                        viewModel: GroupScheduleViewModel(
                            group: group,
                            scheduleSource: dependencies.teachingService,
                            lessonService: dependencies.lessonService
                        )
                    )
                case .attendance(let group):
                    GroupAttendanceView(
                        viewModel: GroupAttendanceViewModel(group: group, teachingService: dependencies.teachingService)
                    )
                case .scores(let group):
                    GroupScoresView(
                        viewModel: GroupScoresViewModel(group: group, teachingService: dependencies.teachingService)
                    )
                case .exams(let group):
                    GroupExamsView(
                        viewModel: GroupExamsViewModel(
                            group: group,
                            teachingService: dependencies.teachingService,
                            lessonService: dependencies.lessonService
                        )
                    )
                }
            }
    }
}

extension View {

    func teacherDestinations() -> some View {
        modifier(TeacherDestinations())
    }
}
