import SwiftUI

struct TeacherHomeView: View {

    @Environment(AuthenticationState.self) private var authenticationState

    @State private var viewModel: TeacherHomeViewModel

    init(viewModel: TeacherHomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(state: viewModel.state, retry: viewModel.load) { overview in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerView

                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                        spacing: 14
                    ) {
                        DashboardTile(icon: "square.grid.2x2.fill", tint: .indigo, title: "Qruplar", value: overview.groups.count)
                        DashboardTile(icon: "person.2.fill", tint: .green, title: "Tələbələr", value: viewModel.studentsCount(overview))
                        DashboardTile(icon: "graduationcap.fill", tint: .orange, title: "İmtahanlar", value: viewModel.upcomingExamsCount(overview))
                        DashboardTile(icon: "calendar", tint: .blue, title: "Növbəti dərslər", value: viewModel.nextLessons(overview).count)
                    }

                    nextLessons(viewModel.nextLessons(overview))
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 20)
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
            subtitle: "Qruplarınız və növbəti dərsləriniz",
            user: authenticationState.currentUser,
            identifier: "teacher_greeting"
        )
    }

    // MARK: - Next Lessons

    private func nextLessons(_ lessons: [ScheduleLesson]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Növbəti dərslər")
                .font(.manropeBold(20))
                .foregroundStyle(.textPrimary)

            if lessons.isEmpty {
                ContentUnavailableView(
                    "Yaxın dərs yoxdur",
                    systemImage: "calendar",
                    description: Text("Qrupların cədvəli yükləndikdə dərslər burada görünəcək.")
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(lessons) { lesson in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(DateFormatting.dayTitle(fromAPI: lesson.date))
                                .font(.manropeRegular(13))
                                .foregroundStyle(.textSecondary)

                            LessonRow(lesson: lesson)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        if lesson.id != lessons.last?.id {
                            InfoDivider()
                        }
                    }
                }
                .cardStyle()
                .accessibilityIdentifier("teacher_next_lessons")
            }
        }
    }
}
