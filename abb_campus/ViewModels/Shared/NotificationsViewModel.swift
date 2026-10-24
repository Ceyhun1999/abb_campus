import Foundation
import Observation

/// The notifications tab of students and teachers.
@MainActor
@Observable
final class NotificationsViewModel {

    private(set) var state: ViewState<[Announcement]> = .idle

    private let feed: any AnnouncementFeed

    init(feed: any AnnouncementFeed) {
        self.feed = feed
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            state = .loaded(try await feed.fetchAnnouncements())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
