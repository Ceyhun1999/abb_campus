import SwiftUI

struct StatCardView: View {

    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let progress: Double
    let progressColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(.manropeRegular(16))
                    .foregroundStyle(.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Text(value)
                .font(.manropeBold(24))
                .foregroundStyle(.textPrimary)

            ProgressBar(
                color: progressColor,
                progress: progress
            )
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            minHeight: 135,
            alignment: .topLeading
        )
        .cardStyle()
    }
}

#Preview {
    HStack(spacing: 14) {
        StatCardView(
            icon: "chart.bar.fill",
            iconColor: .gradeGreen,
            title: "Orta bal",
            value: "88.5",
            progress: 0.885,
            progressColor: .gradeGreenLight
        )

        StatCardView(
            icon: "person.2.fill",
            iconColor: .attendanceBlue,
            title: "Davamiyyət",
            value: "92%",
            progress: 0.92,
            progressColor: .attendanceBlue
        )
    }
    .padding()
}
