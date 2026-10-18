import SwiftUI

struct GroupCardRow: View {

    let group: StudyGroup

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(group.name)
                        .font(.manropeSemiBold(16))
                        .foregroundStyle(.textPrimary)

                    if !group.isActive {
                        StatusBadge(isActive: false, inactiveTitle: "Bitib")
                    }
                }

                Text(group.cardSubtitle)
                    .font(.manropeRegular(13))
                    .foregroundStyle(.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if let progress = group.progress {
                ProgressRing(progress: progress)
            }
        }
        .padding(14)
        .cardStyle(cornerRadius: 18)
    }
}
