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

enum TeacherPositionFilter: String, CaseIterable, Identifiable {
    case all
    case teacher
    case mentor

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "Hamısı"
        case .teacher: return TeacherPosition.teacher.title
        case .mentor: return TeacherPosition.mentor.title
        }
    }

    var queryValue: String? {
        self == .all ? nil : rawValue
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

    func withStatus(_ isActive: Bool) -> Teacher {
        Teacher(
            id: id, firstName: firstName, lastName: lastName, email: email, phone: phone,
            specialty: specialty, position: position, isActive: isActive,
            groupsCount: groupsCount, groups: groups
        )
    }
}
