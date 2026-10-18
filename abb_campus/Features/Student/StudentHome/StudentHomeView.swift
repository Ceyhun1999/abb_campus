import SwiftUI

struct StudentHomeView: View {

    @Environment(AuthenticationState.self) private var authenticationState

    @State private var viewModel: StudentHomeViewModel

    init(viewModel: StudentHomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(state: viewModel.state, retry: viewModel.load) { dashboard in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerView

                    NextLessonCardView(lesson: dashboard.nextLesson)

                    statisticsView(dashboard)

                    announcementsView(dashboard.recentAnnouncements)
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .background(.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        GreetingHeader(
            greeting: viewModel.greeting,
            subtitle: viewModel.subtitle,
            user: authenticationState.currentUser,
            identifier: "home_greeting",
            titleSize: 22,
            subtitleSize: 16,
            avatarSize: 56
        )
    }

    // MARK: - Statistics

    private func statisticsView(_ dashboard: StudentDashboard) -> some View {
        NavigationLink(value: StudentRoute.attendance) {
            StatCardView(
                icon: "person.2.fill",
                iconColor: .attendanceBlue,
                title: "Davamiyyət",
                value: "\(Int(dashboard.attendancePercentage.rounded()))%",
                progress: dashboard.attendancePercentage / 100,
                progressColor: .attendanceBlue
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("attendance_card")
    }

    // MARK: - Announcements

    @ViewBuilder
    private func announcementsView(_ announcements: [Announcement]) -> some View {
        if !announcements.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Son elanlar")
                    .font(.manropeBold(20))
                    .foregroundStyle(.textPrimary)

                AnnouncementsCard(announcements: announcements)
            }
        }
    }
}
