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
    var links: [String] = []
    let target: AnnouncementTarget
    let priority: AnnouncementPriority
    let createdAt: String?

    var audienceTitle: String {
        target.title
    }

    var linkURLs: [URL] {
        links.compactMap(URL.init(string:))
    }
}

extension Announcement {

    private enum CodingKeys: String, CodingKey {
        case id, title, message, links, target, priority, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(Int.self, forKey: .id),
            title: try container.decode(String.self, forKey: .title),
            message: try container.decode(String.self, forKey: .message),
            links: try container.decodeIfPresent([String].self, forKey: .links) ?? [],
            target: try container.decode(AnnouncementTarget.self, forKey: .target),
            priority: try container.decode(AnnouncementPriority.self, forKey: .priority),
            createdAt: try container.decodeIfPresent(String.self, forKey: .createdAt)
        )
    }
}

struct CreateAnnouncementRequest: Encodable, Equatable {
    let title: String
    let message: String
    let target: AnnouncementTarget
    let priority: AnnouncementPriority
    var links: [String] = []
}
