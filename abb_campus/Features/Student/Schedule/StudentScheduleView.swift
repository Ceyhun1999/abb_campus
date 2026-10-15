import SwiftUI

struct StudentScheduleView: View {

    @State private var viewModel: ScheduleViewModel

    init(viewModel: ScheduleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            Picker("Dövr", selection: $viewModel.period) {
                ForEach(SchedulePeriod.allCases) { period in
                    Text(period.title).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.bottom, 8)

            AsyncContentView(
                state: viewModel.state,
                isEmpty: { _ in viewModel.sections.isEmpty },
                emptyTitle: "Dərs yoxdur",
                emptyMessage: viewModel.emptyMessage,
                emptyIcon: "calendar",
                retry: viewModel.load
            ) { _ in
                List(viewModel.sections) { section in
                    Section(section.title) {
                        ForEach(section.lessons) { lesson in
                            LessonRow(lesson: lesson)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await viewModel.load()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Cədvəl")
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - Lesson Row

private struct LessonRow: View {

    let lesson: ScheduleLesson

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 2) {
                Text(lesson.startsAt)
                    .font(.manropeBold(15))
                    .foregroundStyle(.textPrimary)

                Text(lesson.endsAt)
                    .font(.manropeRegular(13))
                    .foregroundStyle(.textSecondary)
            }
            .frame(width: 52)

            Rectangle()
                .fill(Color.blue)
                .frame(width: 3)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.manropeSemiBold(16))
                    .foregroundStyle(.textPrimary)

                if let room = lesson.room {
                    Label("Otaq \(room)", systemImage: "mappin.and.ellipse")
                        .font(.manropeRegular(13))
                        .foregroundStyle(.textSecondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
