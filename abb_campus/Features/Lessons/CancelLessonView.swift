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
