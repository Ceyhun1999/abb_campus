import Foundation

enum AnnouncementTarget: String, Codable, CaseIterable, Identifiable {
    case everyone
    case students
    case teachers

    var id: String { rawValue }

    var title: String {
        switch self {
        case .everyone: return "Hamı"
        case .students: return "Tələbələr"
        case .teachers: return "Müəllim və mentorlar"
        }
    }
}

enum AnnouncementPriority: String, Codable, CaseIterable, Identifiable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var title: String {
        switch self {
        case .low: return "Aşağı"
        case .medium: return "Orta"
        case .high: return "Yüksək"
        }
    }
}

struct Announcement: Decodable, Identifiable, Hashable {
    let id: Int
    let title: String
    let message: String
    let target: AnnouncementTarget
    let priority: AnnouncementPriority
    let createdAt: String?

    var audienceTitle: String {
        target.title
    }
}

struct CreateAnnouncementRequest: Encodable, Equatable {
    let title: String
    let message: String
    let target: AnnouncementTarget
    let priority: AnnouncementPriority
}
