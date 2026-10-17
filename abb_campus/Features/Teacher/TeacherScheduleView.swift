import SwiftUI

struct TeacherScheduleView: View {

    @State private var viewModel: TeacherScheduleViewModel

    init(viewModel: TeacherScheduleViewModel) {
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
                                .lessonActionMenu(for: lesson, actions: viewModel.lessonActions)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await viewModel.load()
                }
                .accessibilityIdentifier("teacher_schedule_list")
            }
        }
        .background(Color(.systemGroupedBackground))
        .lessonActions(viewModel.lessonActions)
        .navigationTitle("Cədvəl")
        .task {
            await viewModel.load()
        }
    }
}
