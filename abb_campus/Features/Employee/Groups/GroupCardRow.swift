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

                Text(subtitle)
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

    private var subtitle: String {
        var parts: [String] = []

        if let count = group.studentsCount {
            parts.append("Tələbə sayı: \(count)")
        }

        if let course = group.course?.name {
            parts.append(course)
        }

        return parts.joined(separator: " · ")
    }
}

struct ProgressRing: View {

    let progress: Int
    var size: CGFloat = 46

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.15), lineWidth: 5)

            Circle()
                .trim(from: 0, to: CGFloat(progress) / 100)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(progress)%")
                .font(.manropeSemiBold(11))
                .foregroundStyle(.textPrimary)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Proqres \(progress) faiz")
    }
}
