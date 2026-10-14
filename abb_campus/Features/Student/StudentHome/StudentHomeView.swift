import SwiftUI

struct StudentHomeView: View {

    @Environment(AuthenticationState.self) private var authenticationState

    @State private var viewModel: StudentHomeViewModel

    init(viewModel: StudentHomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(state: viewModel.state, retry: viewModel.load) { dashboard in
            List {
                headerSection

                nextLessonSection(dashboard.nextLesson)

                Section("Statistika") {
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent {
                            Text(dashboard.averageScore.formatted(.number.precision(.fractionLength(0...1))))
                        } label: {
                            Label("Orta bal", systemImage: "chart.bar.fill")
                        }

                        ProgressView(value: min(max(dashboard.averageScore / 100, 0), 1))
                            .tint(.green)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("average_score_card")

                    NavigationLink(value: StudentRoute.attendance) {
                        VStack(alignment: .leading, spacing: 8) {
                            LabeledContent {
                                Text("\(Int(dashboard.attendancePercentage.rounded()))%")
                            } label: {
                                Label("Davamiyyət", systemImage: "person.2.fill")
                            }

                            ProgressView(value: min(max(dashboard.attendancePercentage / 100, 0), 1))
                        }
                    }
                    .accessibilityIdentifier("attendance_card")
                }

                if !dashboard.recentAnnouncements.isEmpty {
                    Section("Son elanlar") {
                        ForEach(dashboard.recentAnnouncements) { announcement in
                            NavigationLink(value: announcement) {
                                AnnouncementRow(announcement: announcement)
                            }
                        }
                    }
                }
            }
            .font(.manropeRegular(16))
            .refreshable {
                await viewModel.load()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.greeting)
                        .font(.manropeBold(22))
                        .accessibilityIdentifier("home_greeting")

                    Text(viewModel.subtitle)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let user = authenticationState.currentUser {
                    AvatarView(firstName: user.firstName, lastName: user.lastName, size: 52)
                }
            }
            .listRowBackground(Color.clear)
        }
    }

    // MARK: - Next Lesson

    private func nextLessonSection(_ lesson: ScheduleLesson?) -> some View {
        Section("Növbəti dərs") {
            if let lesson {
                Label {
                    Text(lesson.title)
                        .font(.manropeSemiBold(17))
                        .accessibilityIdentifier("next_lesson_title")

                    Text("\(DateFormatting.dayTitle(fromAPI: lesson.date)) · \(lesson.timeRange)")

                    if let room = lesson.room {
                        Text("Otaq \(room)")
                    }
                } icon: {
                    Image(systemName: "calendar")
                }
            } else {
                Text("Yaxın günlərdə dərs yoxdur")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
