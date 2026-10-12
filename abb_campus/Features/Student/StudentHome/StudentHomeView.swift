import SwiftUI

struct StudentHomeView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                NextLessonCardView()
                statisticsView
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
        .background(
            Color(
                red: 249 / 255,
                green: 250 / 255,
                blue: 252 / 255
            )
        )
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Salam, Ceyhun!")
                    .font(.manropeBold(22))
                    .foregroundStyle(
                        Color(
                            red: 41 / 255,
                            green: 43 / 255,
                            blue: 55 / 255
                        )
                    )

                Text("Uğurlu bir gün arzulayırıq!")
                    .font(.manropeRegular(16))
                    .foregroundStyle(
                        Color(
                            red: 150 / 255,
                            green: 154 / 255,
                            blue: 168 / 255
                        )
                    )
            }

            Spacer()

            Image("person")
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
        }
    }

   
    // MARK: - Statistics
    private var statisticsView: some View {
        HStack(spacing: 14) {
            AverageGradeCardView()
            AttendanceCardView()
        }
    }
}

#Preview {
    StudentHomeView()
}
