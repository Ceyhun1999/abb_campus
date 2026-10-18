import SwiftUI

struct RoleCardView: View {

    /// Every role card has this height, whatever the length of its subtitle.
    static let height: CGFloat = 92

    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            IconCircleView(systemName: icon, diameter: 60, iconSize: 24)

            textContent

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity)
        .frame(height: Self.height)
        .cardStyle(cornerRadius: 22)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.manropeSemiBold(21))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(subtitle)
                .font(.manropeRegular(15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
    }
}

#Preview {
    RoleCardView(
        icon: "graduationcap.fill",
        title: "Tələbə",
        subtitle: "Qiymətlərə, dərs cədvəlinə və kurslara bax"
    )
    .padding()
}
