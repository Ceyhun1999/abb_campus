import SwiftUI

struct RoleCardView: View {

    let icon: String
    let title: String
    let subtitle: String

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(.blue.opacity(0.08))
                .frame(width: 76, height: 76)

            Image(systemName: icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.blue)
        }
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Manrope-SemiBold", size: 23))
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.custom("Manrope-Regular", size: 17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
    }

    private var chevronView: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.secondary)
    }

    var body: some View {
        HStack(spacing: 18) {
            iconView

            textContent

            Spacer()

            chevronView
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 112)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
        .shadow(
            color: .black.opacity(0.06),
            radius: 12,
            x: 0,
            y: 5
        )
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
