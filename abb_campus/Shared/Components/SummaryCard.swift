import SwiftUI

struct SummaryCard: View {

    let icon: String
    let title: String
    let value: String
    var tint: Color = .blue

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manropeRegular(12))
                    .foregroundStyle(.textSecondary)

                Text(value)
                    .font(.manropeSemiBold(15))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .cardStyle(cornerRadius: 16)
    }
}

#Preview {
    SummaryCard(icon: "chart.bar.fill", title: "Orta bal", value: "82", tint: .green)
        .padding()
}
