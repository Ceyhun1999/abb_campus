import SwiftUI

struct AnnouncementRow: View {

    let announcement: Announcement

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: announcement.target.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(announcement.priority.color)
                .frame(width: 42, height: 42)
                .background(announcement.priority.color.opacity(0.12))
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

            if !announcement.links.isEmpty {
                Image(systemName: "link")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.textSecondary)
                    .accessibilityLabel("\(announcement.links.count) link")
            }

            if let date = DateFormatting.displayDate(from: announcement.createdAt) {
                Text(date)
                    .font(.manropeRegular(12))
                    .foregroundStyle(.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint("Vaciblik: \(announcement.priority.title)")
    }
}

// MARK: - Badge

struct PriorityBadge: View {

    let priority: AnnouncementPriority

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(priority.color)
                .frame(width: 8, height: 8)

            Text("Vaciblik: \(priority.title)")
                .font(.manropeSemiBold(13))
        }
        .foregroundStyle(priority.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(priority.color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Appearance

extension AnnouncementTarget {

    var icon: String {
        switch self {
        case .everyone: return "megaphone.fill"
        case .students: return "graduationcap.fill"
        case .teachers: return "person.crop.rectangle.fill"
        }
    }
}

extension AnnouncementPriority {

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}
