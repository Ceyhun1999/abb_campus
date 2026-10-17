import SwiftUI

struct StudentTabView: View {

    @Environment(AuthenticationState.self) private var authenticationState
    @Environment(AppearanceSettings.self) private var appearance
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        TabView {
            NavigationStack {
                StudentHomeView(
                    viewModel: StudentHomeViewModel(
                        authenticationState: authenticationState,
                        studentService: dependencies.studentService
                    )
                )
                .studentDestinations()
            }
            .tabItem {
                Label("Ana səhifə", systemImage: "house.fill")
            }

            NavigationStack {
                StudentGradesView(
                    viewModel: StudentGradesViewModel(
                        studentService: dependencies.studentService
                    )
                )
                .studentDestinations()
            }
            .tabItem {
                Label("Qiymətlər", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                StudentScheduleView(
                    viewModel: ScheduleViewModel(
                        studentService: dependencies.studentService
                    )
                )
                .studentDestinations()
            }
            .tabItem {
                Label("Cədvəl", systemImage: "calendar")
            }

            NavigationStack {
                StudentNotificationsView(
                    viewModel: StudentNotificationsViewModel(
                        studentService: dependencies.studentService
                    )
                )
                .studentDestinations()
            }
            .tabItem {
                Label("Bildirişlər", systemImage: "bell.fill")
            }

            ProfileView(
                viewModel: ProfileViewModel(authenticationState: authenticationState, appearance: appearance)
            )
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
        }
    }
}
