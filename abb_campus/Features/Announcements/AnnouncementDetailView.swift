import SwiftUI

struct AnnouncementDetailView: View {

    let announcement: Announcement

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AnnouncementRow(announcement: announcement)
                    .padding(16)
                    .cardStyle()

                PriorityBadge(priority: announcement.priority)

                Text(announcement.message)
                    .font(.manropeRegular(16))
                    .foregroundStyle(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .cardStyle()

                if !announcement.linkURLs.isEmpty {
                    linksCard
                }
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.vertical, 20)
        }
        .background(.appBackground)
        .navigationTitle("Elan")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Links

    private var linksCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(announcement.linkURLs, id: \.self) { url in
                Link(destination: url) {
                    HStack(spacing: 12) {
                        Image(systemName: "link")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.blue)
                            .frame(width: 26)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(url.host() ?? url.absoluteString)
                                .font(.manropeSemiBold(15))
                                .foregroundStyle(.textPrimary)

                            Text(url.absoluteString)
                                .font(.manropeRegular(12))
                                .foregroundStyle(.textSecondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.textSecondary)
                    }
                    .padding(16)
                }
                .accessibilityIdentifier("announcement_link")

                if url != announcement.linkURLs.last {
                    InfoDivider()
                }
            }
        }
        .cardStyle()
    }
}
