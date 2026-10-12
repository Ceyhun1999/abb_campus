import Foundation

struct Teacher: Decodable, Identifiable, Hashable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let specialty: String?
    let isActive: Bool
    let groupsCount: Int?
    let groups: [StudyGroup]?

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
