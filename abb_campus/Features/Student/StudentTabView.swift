import SwiftUI

struct StudentTabView: View {

    @Environment(AuthenticationState.self) private var authenticationState

    var body: some View {
        TabView {
            StudentHomeView(
                viewModel: StudentHomeViewModel(
                    authenticationState: authenticationState
                )
            )
            .tabItem {
                Label("Ana səhifə", systemImage: "house.fill")
            }

            StudentGradesView()
                .tabItem {
                    Label("Qiymətlər", systemImage: "chart.bar.fill")
                }

            StudentScheduleView()
                .tabItem {
                    Label("Cədvəl", systemImage: "calendar")
                }

            StudentNotificationsView()
                .tabItem {
                    Label("Bildirişlər", systemImage: "bell.fill")
                }

            ProfileView(
                viewModel: ProfileViewModel(
                    authenticationState: authenticationState
                )
            )
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
        }
    }
}
