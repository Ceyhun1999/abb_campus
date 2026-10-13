import SwiftUI

struct AnnouncementRow: View {

    let announcement: Announcement

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: announcement.target.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(announcement.target.tint)
                .frame(width: 42, height: 42)
                .background(announcement.target.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(announcement.title)
                    .font(.manropeSemiBold(15))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)

                Text(announcement.audienceTitle)
                    .font(.manropeRegular(13))
                    .foregroundStyle(.textSecondary)
            }

            Spacer(minLength: 0)

            if let date = DateFormatting.displayDate(from: announcement.createdAt) {
                Text(date)
                    .font(.manropeRegular(12))
                    .foregroundStyle(.textSecondary)
            }
        }
    }
}

extension AnnouncementTarget {

    var icon: String {
        switch self {
        case .everyone: return "megaphone.fill"
        case .students: return "graduationcap.fill"
        case .teachers: return "person.crop.rectangle.fill"
        case .group: return "square.grid.2x2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .everyone: return .orange
        case .students: return .blue
        case .teachers: return .purple
        case .group: return .red
        }
    }
}
