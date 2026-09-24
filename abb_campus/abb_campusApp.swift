import SwiftUI

@main
struct abb_campusApp: App {

    @State private var authenticationState = AuthenticationState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authenticationState)
        }
    }
}
