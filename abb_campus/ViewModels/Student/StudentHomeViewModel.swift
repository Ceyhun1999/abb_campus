import Foundation
import Observation

@MainActor
@Observable
final class StudentHomeViewModel {

    private let authenticationState: AuthenticationState

    init(authenticationState: AuthenticationState) {
        self.authenticationState = authenticationState
    }

    var greeting: String {
        guard let firstName = authenticationState.currentUser?.firstName,
              !firstName.isEmpty else {
            return "Salam!"
        }

        return "Salam, \(firstName)!"
    }

    var subtitle: String {
        "Uğurlu bir gün arzulayırıq!"
    }
}
