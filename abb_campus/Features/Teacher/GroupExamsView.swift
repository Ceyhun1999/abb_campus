import SwiftUI

struct GroupExamsView: View {

    @State private var viewModel: GroupExamsViewModel

    init(viewModel: GroupExamsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        AsyncContentView(state: viewModel.state, retry: viewModel.load) { _ in
            List {
                Section {
                    PrimaryButton(title: "İmtahan təyin et") {
                        viewModel.showExamForm()
                    }
                    .disabled(!viewModel.canSchedule)
                    .opacity(viewModel.canSchedule ? 1 : 0.5)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .accessibilityIdentifier("schedule_exam_button")
                }

                examSection("Gələcək imtahanlar", viewModel.upcomingExams, empty: "Təyin edilmiş imtahan yoxdur.")
                examSection("Keçmiş imtahanlar", viewModel.pastExams, empty: "Keçmiş imtahan yoxdur.")
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await viewModel.load()
            }
        }
        .background(Color.groupedBackground)
        .navigationTitle("İmtahanlar")
        .navigationBarTitleDisplayMode(.inline)
        .lessonActions(viewModel.lessonActions)
        .importFlow(viewModel.importFlow)
        .sheet(isPresented: $viewModel.isExamFormPresented) {
            if let formViewModel = viewModel.examFormViewModel {
                ExamFormView(viewModel: formViewModel, onSaved: viewModel.examScheduled)
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func examSection(_ title: String, _ exams: [ScheduleLesson], empty: String) -> some View {
        Section(title) {
            if exams.isEmpty {
                Text(empty)
                    .font(.manropeRegular(14))
                    .foregroundStyle(.textSecondary)
            }

            ForEach(exams) { exam in
                VStack(alignment: .leading, spacing: 8) {
                    Text(DateFormatting.dayTitle(fromAPI: exam.date))
                        .font(.manropeRegular(13))
                        .foregroundStyle(.textSecondary)

                    LessonRow(lesson: exam)

                    if viewModel.canUploadScores(exam) {
                        Button(exam.hasScores ? "Balları yenidən yüklə" : "Balları yüklə") {
                            viewModel.showScoresImport(for: exam)
                        }
                        .font(.manropeSemiBold(15))
                        .buttonStyle(.borderless)
                        .accessibilityIdentifier("upload_exam_scores_\(exam.id)")
                    }
                }
                .lessonActionMenu(for: exam, actions: viewModel.lessonActions)
            }
        }
    }
}

// MARK: - Exam Form

struct ExamFormView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ExamFormViewModel

    let onSaved: (ScheduleLesson) -> Void

    init(viewModel: ExamFormViewModel, onSaved: @escaping (ScheduleLesson) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            Form {
                Section {
                    TextField("İmtahanın adı (məsələn, Modul 1 imtahanı)", text: $viewModel.title)
                        .accessibilityIdentifier("exam_title_field")

                    if let error = viewModel.titleError {
                        Text(error)
                            .font(.manropeRegular(13))
                            .foregroundStyle(.red)
                    }
                }

                Section("Vaxt") {
                    DatePicker("Tarix", selection: $viewModel.date, in: viewModel.dateRange, displayedComponents: .date)
                    DatePicker("Başlayır", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                    DatePicker("Bitir", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)

                    if let error = viewModel.timeError {
                        Text(error)
                            .font(.manropeRegular(13))
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    TextField("Otaq (istəyə bağlı)", text: $viewModel.room)
                } footer: {
                    Text("Qrupun tələbələri imtahan haqqında bildiriş alacaq və onu cədvəldə görəcək.")
                }
            }
            .navigationTitle("Yeni imtahan")
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
                        Button("Təyin et") {
                            Task {
                                if let exam = await viewModel.save() {
                                    onSaved(exam)
                                }
                            }
                        }
                        .disabled(!viewModel.canSave)
                        .accessibilityIdentifier("exam_save_button")
                    }
                }
            }
            .errorAlert(viewModel.errorMessage, onDismiss: viewModel.dismissError)
            .interactiveDismissDisabled(viewModel.isSaving)
        }
    }
}
