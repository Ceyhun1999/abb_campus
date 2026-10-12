import Foundation
@testable import abb_campus

enum TestError: Error {
    case generic
}

extension User {

    static func stub(
        firstName: String = "Ceyhun",
        lastName: String = "Rzayev",
        email: String = "student@abb.local",
        role: UserRole = .student
    ) -> User {
        User(
            id: 1,
            firstName: firstName,
            lastName: lastName,
            email: email,
            role: role
        )
    }
}

extension LoginResponse {

    static func stub(
        token: String = "test-token",
        user: User = .stub()
    ) -> LoginResponse {
        LoginResponse(
            success: true,
            data: LoginData(token: token, user: user)
        )
    }
}
