import Testing
@testable import abb_campus

@MainActor
@Suite("RoleSelectionViewModel")
struct RoleSelectionViewModelTests {

    @Test("Selecting a role stores it and opens the login screen", arguments: UserRole.allCases)
    func selectRole(role: UserRole) {
        let state = AuthenticationState(
            secureStorage: MockSecureStorage(),
            authService: MockAuthService()
        )
        let sut = RoleSelectionViewModel(authenticationState: state)

        sut.selectRole(role)

        #expect(state.selectedRole == role)
        #expect(sut.isLoginPresented)
    }

    @Test("All roles are offered")
    func rolesList() {
        let sut = RoleSelectionViewModel(
            authenticationState: AuthenticationState(
                secureStorage: MockSecureStorage(),
                authService: MockAuthService()
            )
        )

        #expect(sut.roles == [.student, .teacher, .employee])
    }
}
