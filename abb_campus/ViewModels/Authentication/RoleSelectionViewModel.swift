import Foundation
import Observation

@Observable
final class RoleSelectionViewModel {
    private let authenticationState: AuthenticationState
    
    init(authenticationState: AuthenticationState) {
        self.authenticationState = authenticationState
    }
    
    func selectRole(_ role: UserRole) {
        authenticationState.selectRole(role)
    }
}
