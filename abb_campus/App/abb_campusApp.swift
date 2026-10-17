import SwiftUI

@main
struct abb_campusApp: App {

    private let dependencies: AppDependencies

    @State private var authenticationState: AuthenticationState
    @State private var appearance: AppearanceSettings

    init() {
        let dependencies = AppDependencies.current()

        self.dependencies = dependencies
        _authenticationState = State(
            initialValue: dependencies.makeAuthenticationState()
        )
        _appearance = State(
            initialValue: dependencies.makeAppearanceSettings()
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authenticationState)
                .environment(appearance)
                .preferredColorScheme(appearance.mode.colorScheme)
                .environment(\.dependencies, dependencies)
        }
    }
}
