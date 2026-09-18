import Foundation

struct LoginResponse: Decodable {
    let success: Bool
    let data: LoginData
}

struct LoginData: Decodable {
    let token: String
    let user: User
}

struct User: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let role: UserRole
}
