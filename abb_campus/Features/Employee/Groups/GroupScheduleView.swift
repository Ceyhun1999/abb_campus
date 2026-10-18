import SwiftUI

struct GroupScheduleView: View {

    @State private var viewModel: GroupScheduleViewModel

    init(viewModel: GroupScheduleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 12) {
            if viewModel.canImport {
                importSection
            }

            SchedulePeriodList(
                period: $viewModel.period,
                state: viewModel.state,
                sections: viewModel.sections,
                emptyMessage: viewModel.emptyMessage,
                lessonActions: viewModel.lessonActions,
                listIdentifier: "group_schedule_list",
                spacing: 12,
                load: viewModel.load
            )
        }
        .padding(.top, 8)
        .background(Color.groupedBackground)
        .lessonActions(viewModel.lessonActions)
        .importFlow(viewModel.importFlow)
        .navigationTitle("Dərs cədvəli")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Import

    private var importSection: some View {
        VStack(spacing: 8) {
            PrimaryButton(title: "Excel-dən cədvəl idxal et") {
                viewModel.showImport()
            }
            .disabled(viewModel.importBlockedReason != nil)
            .opacity(viewModel.importBlockedReason == nil ? 1 : 0.5)
            .accessibilityIdentifier("import_schedule_button")

            if let reason = viewModel.importBlockedReason {
                Text(reason)
                    .font(.manropeRegular(14))
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
    }
}
