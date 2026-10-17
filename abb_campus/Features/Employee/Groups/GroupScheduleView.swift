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

            Picker("Dövr", selection: $viewModel.period) {
                ForEach(SchedulePeriod.allCases) { period in
                    Text(period.title).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AppLayout.horizontalPadding)

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
                .accessibilityIdentifier("group_schedule_list")
            }
        }
        .padding(.top, 8)
        .background(Color(.systemGroupedBackground))
        .lessonActions(viewModel.lessonActions)
        .navigationTitle("Dərs cədvəli")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.isImportPresented) {
            if let importViewModel = viewModel.importViewModel {
                GroupImportView(viewModel: importViewModel)
            }
        }
        .onChange(of: viewModel.isImportPresented) { _, isPresented in
            Task {
                await viewModel.importPresentationChanged(isPresented)
            }
        }
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
