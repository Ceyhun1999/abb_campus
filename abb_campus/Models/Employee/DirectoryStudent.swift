import Foundation

struct DirectoryStudent: Decodable, Identifiable, Hashable {

    struct GroupReference: Decodable, Hashable {
        let id: Int
        let name: String
        var courseName: String?
    }

    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let isActive: Bool
    let group: GroupReference?
    let createdAt: String?

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var groupSubtitle: String {
        guard let group else {
            return "Qrupsuz"
        }

        return [group.name, group.courseName].compactMap { $0 }.joined(separator: " · ")
    }
}
