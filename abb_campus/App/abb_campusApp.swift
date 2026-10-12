import SwiftUI

@main
struct abb_campusApp: App {

    private let dependencies: AppDependencies

    @State private var authenticationState: AuthenticationState

    init() {
        let dependencies = AppDependencies.current()

        self.dependencies = dependencies
        _authenticationState = State(
            initialValue: dependencies.makeAuthenticationState()
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authenticationState)
                .environment(\.dependencies, dependencies)
        }
    }
}
