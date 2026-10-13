import Foundation

enum TeacherPosition: String, Decodable, Hashable {
    case teacher
    case mentor

    var title: String {
        switch self {
        case .teacher: return "Müəllim"
        case .mentor: return "Mentor"
        }
    }
}

struct Teacher: Decodable, Identifiable, Hashable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let specialty: String?
    let position: TeacherPosition?
    let isActive: Bool
    let groupsCount: Int?
    let groups: [StudyGroup]?

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var positionTitle: String {
        position?.title ?? TeacherPosition.teacher.title
    }
}
