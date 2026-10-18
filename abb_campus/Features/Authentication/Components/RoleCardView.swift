import SwiftUI

struct RoleCardView: View {

    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 18) {
            IconCircleView(systemName: icon)

            textContent

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, minHeight: 112)
        .cardStyle(cornerRadius: 22)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.manropeSemiBold(23))
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.manropeRegular(17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
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
