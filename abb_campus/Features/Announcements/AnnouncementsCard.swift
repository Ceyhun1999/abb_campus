import SwiftUI

/// Announcements in one card; each opens its details.
struct AnnouncementsCard: View {

    let announcements: [Announcement]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(announcements) { announcement in
                NavigationLink(value: announcement) {
                    AnnouncementRow(announcement: announcement)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)

                if announcement.id != announcements.last?.id {
                    InfoDivider()
                }
            }
        }
        .cardStyle()
    }
}
