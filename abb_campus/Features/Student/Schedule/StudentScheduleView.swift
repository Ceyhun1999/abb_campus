import SwiftUI

struct StudentScheduleView: View {

    @State private var viewModel: ScheduleViewModel

    init(viewModel: ScheduleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        SchedulePeriodList(
            period: $viewModel.period,
            state: viewModel.state,
            sections: viewModel.sections,
            emptyMessage: viewModel.emptyMessage,
            load: viewModel.load
        )
        .background(Color.groupedBackground)
        .navigationTitle("Cədvəl")
        .task {
            await viewModel.load()
        }
    }
}
