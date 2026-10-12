import SwiftUI

struct NextLessonCardView: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(
                    Color.white.opacity(0.18)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text("Növbəti dərs")
                    .font(.manropeRegular(16))
                    .foregroundStyle(.white.opacity(0.85))

                Text("iOS Development")
                    .font(.manropeSemiBold(20))
                    .foregroundStyle(.white)

                Text("10:00 – 11:50")
                    .font(.manropeRegular(15))
                    .foregroundStyle(.white.opacity(0.95))

                Text("Room 402")
                    .font(.manropeRegular(15))
                    .foregroundStyle(.white.opacity(0.95))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(
                    Color.white.opacity(0.14)
                )
                .clipShape(Circle())
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.brandBlue)
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
    }
}

#Preview {
    NextLessonCardView()
}
