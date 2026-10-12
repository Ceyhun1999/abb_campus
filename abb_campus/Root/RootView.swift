import SwiftUI

struct RootView: View {

    @Environment(AuthenticationState.self) private var authenticationState

    var body: some View {
        Group {
            if authenticationState.isRestoringSession {
                LaunchLoadingView()

            } else if let user = authenticationState.currentUser,
                      authenticationState.isAuthenticated {
                authenticatedView(for: user.role)

            } else {
                NavigationStack {
                    AuthenticationView()
                }
            }
        }
        .animation(.default, value: authenticationState.isAuthenticated)
        .task {
            await authenticationState.restoreSession()
        }
    }

    @ViewBuilder
    private func authenticatedView(for role: UserRole) -> some View {
        switch role {
        case .student:
            StudentTabView()

        case .teacher, .employee:
            ComingSoonView(
                viewModel: ProfileViewModel(
                    authenticationState: authenticationState
                )
            )
        }
    }
}
