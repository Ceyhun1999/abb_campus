import SwiftUI

struct CancelLessonView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CancelLessonViewModel

    let onCancelled: (ScheduleLesson) -> Void

    init(viewModel: CancelLessonViewModel, onCancelled: @escaping (ScheduleLesson) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onCancelled = onCancelled
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.lesson.title)
                            .font(.manropeSemiBold(16))

                        Text(viewModel.lessonSummary)
                            .font(.manropeRegular(14))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }

                Section("Səbəb") {
                    Picker("Səbəb", selection: $viewModel.reason) {
                        ForEach(CancelReason.allCases) { reason in
                            Text(reason.title).tag(reason)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .accessibilityIdentifier("cancel_reason_picker")

                    TextField(viewModel.notePlaceholder, text: $viewModel.note, axis: .vertical)
                        .lineLimit(2...4)
                        .accessibilityIdentifier("cancel_note_field")
                }

                Section {
                    Text("Qrupun tələbələrinə bildiriş göndəriləcək. Dərs cədvəldə səbəbi ilə qalacaq.")
                        .font(.manropeRegular(13))
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Bağla") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button("Ləğv et") {
                            Task {
                                if let lesson = await viewModel.submit() {
                                    onCancelled(lesson)
                                }
                            }
                        }
                        .disabled(!viewModel.canSubmit)
                        .accessibilityIdentifier("cancel_lesson_submit")
                    }
                }
            }
            .errorAlert(viewModel.errorMessage, onDismiss: viewModel.dismissError)
            .interactiveDismissDisabled(viewModel.isSaving)
        }
        .presentationDetents([.large])
    }
}

// MARK: - Lesson Actions

private struct LessonActionsModifier: ViewModifier {

    @Bindable var actions: LessonActions

    func body(content: Content) -> some View {
        content
            .sheet(item: $actions.cancelViewModel) { cancelViewModel in
                CancelLessonView(viewModel: cancelViewModel, onCancelled: actions.cancelFinished)
            }
            .confirmationDialog(
                "Dərs yenidən cədvələ qaytarılsın? Tələbələrə bildiriş göndəriləcək.",
                isPresented: Binding(
                    get: { actions.lessonToRestore != nil },
                    set: { if !$0 { actions.lessonToRestore = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Bərpa et") {
                    Task {
                        await actions.restore()
                    }
                }

                Button("İmtina", role: .cancel) {}
            }
            .errorAlert(actions.errorMessage, onDismiss: actions.dismissError)
    }
}

private struct LessonActionMenu: ViewModifier {

    let lesson: ScheduleLesson
    let actions: LessonActions

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing) {
                buttons
            }
            .contextMenu {
                buttons
            }
    }

    @ViewBuilder
    private var buttons: some View {
        if actions.canCancel(lesson) {
            Button(role: .destructive) {
                actions.startCancel(lesson)
            } label: {
                Label("Ləğv et", systemImage: "calendar.badge.minus")
            }
        } else if actions.canRestore(lesson) {
            Button {
                actions.askRestore(lesson)
            } label: {
                Label("Bərpa et", systemImage: "arrow.uturn.backward")
            }
            .tint(.blue)
        }
    }
}

extension View {

    /// Presents the cancel sheet, the restore confirmation and errors of `actions`.
    func lessonActions(_ actions: LessonActions) -> some View {
        modifier(LessonActionsModifier(actions: actions))
    }

    /// Swipe and long-press actions to cancel or restore one lesson.
    func lessonActionMenu(for lesson: ScheduleLesson, actions: LessonActions) -> some View {
        modifier(LessonActionMenu(lesson: lesson, actions: actions))
    }
}

// MARK: - Import Flow

private struct ImportFlowModifier: ViewModifier {

    @Bindable var flow: ImportFlow

    func body(content: Content) -> some View {
        content
            .navigationDestination(isPresented: $flow.isPresented) {
                if let viewModel = flow.viewModel {
                    GroupImportView(viewModel: viewModel)
                }
            }
            .onChange(of: flow.isPresented) { _, isPresented in
                Task {
                    await flow.presentationChanged(isPresented)
                }
            }
    }
}

extension View {

    /// Pushes the import screen of `flow` and reloads when it closes.
    func importFlow(_ flow: ImportFlow) -> some View {
        modifier(ImportFlowModifier(flow: flow))
    }
}
