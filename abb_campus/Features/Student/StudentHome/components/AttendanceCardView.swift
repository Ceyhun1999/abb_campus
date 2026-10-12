import SwiftUI

struct AttendanceCardView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(
                        Color(
                            red: 111 / 255,
                            green: 166 / 255,
                            blue: 244 / 255
                        )
                    )

                Text("Davamiyyət")
                    .font(.manropeRegular(16))
                    .foregroundStyle(
                        Color(
                            red: 110 / 255,
                            green: 115 / 255,
                            blue: 130 / 255
                        )
                    )
            }

            Text("92%")
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
                    red: 99 / 255,
                    green: 166 / 255,
                    blue: 244 / 255
                ),
                progress: 0.92
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
