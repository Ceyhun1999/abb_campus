import SwiftUI

struct StudentHomeView: View {

    @State private var viewModel: StudentHomeViewModel

    init(viewModel: StudentHomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

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
        .background(.appBackground)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greeting)
                    .font(.manropeBold(22))
                    .foregroundStyle(.textPrimary)
                    .accessibilityIdentifier("home_greeting")

                Text(viewModel.subtitle)
                    .font(.manropeRegular(16))
                    .foregroundStyle(.textSecondary)
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
    }
}
