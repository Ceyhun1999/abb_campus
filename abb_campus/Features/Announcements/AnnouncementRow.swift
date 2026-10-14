import SwiftUI

struct AnnouncementRow: View {

    let announcement: Announcement

    var body: some View {
        LabeledContent {
            if let date = DateFormatting.displayDate(from: announcement.createdAt) {
                Text(date)
                    .font(.footnote)
            }
        } label: {
            Label {
                Text(announcement.title)
                    .font(.manropeSemiBold(16))
                    .lineLimit(1)

                Text(announcement.audienceTitle)
            } icon: {
                Image(systemName: announcement.target.icon)
                    .foregroundStyle(announcement.target.tint)
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
