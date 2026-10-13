import SwiftUI

struct AnnouncementDetailView: View {

    let announcement: Announcement

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AnnouncementRow(announcement: announcement)
                    .padding(16)
                    .cardStyle()

                Text(announcement.message)
                    .font(.manropeRegular(16))
                    .foregroundStyle(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .cardStyle()
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.vertical, 20)
        }
        .background(.appBackground)
        .navigationTitle("Elan")
        .navigationBarTitleDisplayMode(.inline)
    }
}
