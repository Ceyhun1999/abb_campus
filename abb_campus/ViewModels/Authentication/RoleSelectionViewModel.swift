import Foundation
import Observation

@MainActor
@Observable
final class RoleSelectionViewModel {

    var isLoginPresented = false

    let roles = UserRole.allCases

    private let authenticationState: AuthenticationState

    init(authenticationState: AuthenticationState) {
        self.authenticationState = authenticationState
    }

    func selectRole(_ role: UserRole) {
        authenticationState.selectRole(role)
        isLoginPresented = true
    }
}
