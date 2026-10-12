import Foundation

enum AnnouncementTarget: String, Codable, CaseIterable, Identifiable {
    case everyone
    case students
    case teachers
    case group

    var id: String { rawValue }

    var title: String {
        switch self {
        case .everyone: return "Hamı"
        case .students: return "Bütün tələbələr"
        case .teachers: return "Bütün müəllimlər"
        case .group: return "Müəyyən qrup"
        }
    }
}

struct Announcement: Decodable, Identifiable, Hashable {
    let id: Int
    let title: String
    let message: String
    let target: AnnouncementTarget
    let groupId: Int?
    let groupName: String?
    let createdAt: String?

    var audienceTitle: String {
        if target == .group, let groupName {
            return groupName
        }

        return target.title
    }
}

struct CreateAnnouncementRequest: Encodable, Equatable {
    let title: String
    let message: String
    let target: AnnouncementTarget
    let groupId: Int?
}
