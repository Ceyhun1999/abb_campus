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
                .font(.manropeRegular(16))
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

private struct LessonRow: View {

    let lesson: ScheduleLesson

    var body: some View {
        LabeledContent {
            Text(lesson.timeRange)
        } label: {
            Text(lesson.title)
                .font(.manropeSemiBold(16))

            if let room = lesson.room {
                Text("Otaq \(room)")
            }
        }
    }
}
