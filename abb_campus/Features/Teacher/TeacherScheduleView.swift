import SwiftUI

struct TeacherScheduleView: View {

    @State private var viewModel: TeacherScheduleViewModel

    init(viewModel: TeacherScheduleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        SchedulePeriodList(
            period: $viewModel.period,
            state: viewModel.state,
            sections: viewModel.sections,
            emptyMessage: viewModel.emptyMessage,
            lessonActions: viewModel.lessonActions,
            listIdentifier: "teacher_schedule_list",
            load: viewModel.load
        )
        .background(Color.groupedBackground)
        .lessonActions(viewModel.lessonActions)
        .navigationTitle("Cədvəl")
        .task {
            await viewModel.load()
        }
    }
}
