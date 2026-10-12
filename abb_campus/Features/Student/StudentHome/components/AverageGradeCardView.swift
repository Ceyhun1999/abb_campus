import SwiftUI

struct AverageGradeCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(
                        Color(
                            red: 111 / 255,
                            green: 199 / 255,
                            blue: 126 / 255
                        )
                    )

                Text("Orta bal")
                    .font(.manropeRegular(16))
                    .foregroundStyle(
                        Color(
                            red: 110 / 255,
                            green: 115 / 255,
                            blue: 130 / 255
                        )
                    )
            }

            Text("88.5")
                .font(.manropeBold(24))
                .foregroundStyle(
                    Color(
                        red: 41 / 255,
                        green: 43 / 255,
                        blue: 55 / 255
                    )
                )

            ProgressBar(
                color: Color(
                    red: 182 / 255,
                    green: 230 / 255,
                    blue: 181 / 255
                ),
                progress: 0.885
            )

        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            minHeight: 135,
            alignment: .topLeading
        )
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .shadow(
            color: .black.opacity(0.04),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}
