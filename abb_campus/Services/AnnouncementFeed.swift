import Foundation

/// Loads the academy announcements and group notices meant for the signed-in user.
/// Students and teachers read the same feed.
protocol AnnouncementFeed: Sendable {
    func fetchAnnouncements() async throws -> [Announcement]
}
