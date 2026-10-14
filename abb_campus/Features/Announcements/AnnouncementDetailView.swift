import SwiftUI

struct AnnouncementDetailView: View {

    let announcement: Announcement

    var body: some View {
        List {
            Section {
                AnnouncementRow(announcement: announcement)
            }

            Section {
                Text(announcement.message)
            }
        }
        .font(.manropeRegular(16))
        .navigationTitle("Elan")
        .navigationBarTitleDisplayMode(.inline)
    }
}
