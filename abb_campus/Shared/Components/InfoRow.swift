import SwiftUI

struct InfoRow: View {

    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.blue)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manropeRegular(13))
                    .foregroundStyle(.textSecondary)

                Text(value)
                    .font(.manropeSemiBold(16))
                    .foregroundStyle(.textPrimary)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
    }
}

/// A card that stacks `InfoRow`s; put `InfoDivider()` between rows.
struct InfoCard<Content: View>: View {

    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .cardStyle()
    }
}

struct InfoDivider: View {

    var body: some View {
        Divider()
            .padding(.leading, 56)
    }
}
