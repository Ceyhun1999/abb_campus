import SwiftUI

struct RootView: View {

    @Environment(AuthenticationState.self)
    private var authenticationState

    var body: some View {
        Group {
            if authenticationState.isRestoringSession {
                ProgressView()

            } else if authenticationState.isAuthenticated {
                Text("Login uğurludur")

            } else {
                NavigationStack {
                    AuthenticationView()
                }
            }
        }
        .task {
            await authenticationState.restoreSession()
        }
    }
}
