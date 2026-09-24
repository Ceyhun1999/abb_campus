import Foundation
import Observation

@Observable
final class AppSession {

    var currentUser: User?
    var token: String?

    var isAuthenticated: Bool {
        currentUser != nil && token != nil
    }

    func startSession(
        user: User,
        token: String
    ) {
        currentUser = user
        self.token = token
    }
    
    func endSession() {
        currentUser = nil
        token = nil
    }
}
