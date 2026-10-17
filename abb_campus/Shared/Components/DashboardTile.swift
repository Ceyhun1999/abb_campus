import SwiftUI

struct DashboardTile: View {

    let icon: String
    let tint: Color
    let title: String
    let value: Int
    var showsChevron = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manropeRegular(14))
                    .foregroundStyle(.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("\(value)")
                    .font(.manropeBold(20))
                    .foregroundStyle(.textPrimary)
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(cornerRadius: 18)
    }
}
