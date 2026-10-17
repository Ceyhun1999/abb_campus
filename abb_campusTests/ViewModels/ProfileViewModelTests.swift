import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("ProfileViewModel & StudentHomeViewModel")
struct ProfileViewModelTests {

    private let authService = MockAuthService()
    private let secureStorage = MockSecureStorage()
    private let state: AuthenticationState

    init() throws {
        state = AuthenticationState(
            secureStorage: secureStorage,
            authService: authService
        )
        try state.startSession(user: .stub(), token: "token")
    }

    @Test("Profile shows user information")
    func userInfo() {
        let sut = ProfileViewModel(authenticationState: state, appearance: AppearanceSettings(preferences: MockPreferencesStore()))

        #expect(sut.fullName == "Ceyhun Rzayev")
        #expect(sut.initials == "CR")
        #expect(sut.email == "student@abb.local")
        #expect(sut.roleTitle == "Tələbə")
    }

    @Test("Choosing an appearance in the profile applies and saves it")
    func profileAppearance() {
        let preferences = MockPreferencesStore()
        let appearance = AppearanceSettings(preferences: preferences)
        let sut = ProfileViewModel(authenticationState: state, appearance: appearance)
        #expect(sut.appearanceMode == .system)

        sut.appearanceMode = .dark

        #expect(appearance.mode == .dark)
        #expect(preferences.appearanceMode == .dark)

        sut.appearanceMode = .dark
        sut.appearanceMode = .light

        #expect(preferences.savedAppearanceModes == [.dark, .light])
    }

    @Test("The saved appearance is used on the next launch")
    func savedAppearanceIsRestored() {
        let preferences = MockPreferencesStore()
        preferences.appearanceMode = .dark

        #expect(AppearanceSettings(preferences: preferences).mode == .dark)
    }

    @Test("UserDefaults keeps the appearance and falls back to the system for unknown values")
    func appearanceInUserDefaults() throws {
        let suite = "appearance-test-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = UserDefaultsPreferencesStore(defaults: defaults)

        #expect(store.appearanceMode == .system)

        store.setAppearanceMode(.light)
        #expect(UserDefaultsPreferencesStore(defaults: defaults).appearanceMode == .light)

        defaults.set("sepia", forKey: "appearanceMode")
        #expect(store.appearanceMode == .system)
    }

    @Test("Logout clears the session and revokes the token")
    func logout() async {
        let sut = ProfileViewModel(authenticationState: state, appearance: AppearanceSettings(preferences: MockPreferencesStore()))

        sut.requestLogout()
        #expect(sut.isLogoutConfirmationPresented)

        await sut.logout()

        #expect(state.isAuthenticated == false)
        #expect(authService.logoutTokens == ["token"])
        #expect(secureStorage.storage.isEmpty)
        #expect(sut.isLoggingOut == false)
    }

    @Test("Home greeting uses the first name")
    func homeGreeting() {
        let sut = StudentHomeViewModel(authenticationState: state, studentService: MockStudentService())

        #expect(sut.greeting == "Salam, Ceyhun!")
    }

    @Test("Home greeting falls back when there is no user")
    func homeGreetingWithoutUser() async {
        await state.logout()
        let sut = StudentHomeViewModel(authenticationState: state, studentService: MockStudentService())

        #expect(sut.greeting == "Salam!")
    }
}
