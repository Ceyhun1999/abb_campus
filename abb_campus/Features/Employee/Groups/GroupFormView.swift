import SwiftUI

struct GroupFormView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: GroupFormViewModel

    let onSaved: () -> Void

    init(viewModel: GroupFormViewModel, onSaved: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            AsyncContentView(state: viewModel.options, retry: viewModel.loadOptions) { options in
                form(options)
            }
            .errorAlert(viewModel.errorMessage, onDismiss: viewModel.dismissError)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ləğv et") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button(viewModel.saveTitle) {
                            Task {
                                if await viewModel.save() != nil {
                                    onSaved()
                                }
                            }
                        }
                        .disabled(viewModel.options.value == nil)
                        .accessibilityIdentifier("group_form_save")
                    }
                }
            }
        }
        .task {
            await viewModel.loadOptions()
        }
    }

    private func form(_ options: GroupFormOptions) -> some View {
        @Bindable var viewModel = viewModel

        return Form {
            Section("Qrup") {
                TextField("Qrup adı, məs. IOS-03", text: $viewModel.name)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("group_form_name")

                Picker("Kurs", selection: $viewModel.selectedCourseId) {
                    Text("Seçilməyib").tag(Int?.none)

                    ForEach(options.courses) { course in
                        Text(course.name).tag(Optional(course.id))
                    }
                }
                .pickerStyle(.navigationLink)

                Picker("Müəllim", selection: $viewModel.selectedTeacherId) {
                    Text("Təyin edilməyib").tag(Int?.none)

                    ForEach(viewModel.availableTeachers) { teacher in
                        Text(teacher.fullName).tag(Optional(teacher.id))
                    }
                }
                .pickerStyle(.navigationLink)
                .disabled(!viewModel.hasCourse)
            }

            mentorsSection

            Section("Müddət") {
                DatePicker("Başlama tarixi", selection: $viewModel.startDate, displayedComponents: .date)

                DatePicker("Bitmə tarixi", selection: $viewModel.endDate, displayedComponents: .date)
            }

            if !viewModel.removedInactiveStaff.isEmpty {
                Section {
                    Label(
                        "Deaktiv: \(viewModel.removedInactiveStaff.joined(separator: ", ")). Yadda saxlayanda qrupdan çıxarılacaq.",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(.red)
                }
            }

            if viewModel.isEditing {
                Section("Status") {
                    Toggle("Aktiv qrup", isOn: $viewModel.isActive)
                }
            }
        }
    }

    // MARK: - Mentors

    private var mentorsSection: some View {
        Section("Mentorlar") {
            if !viewModel.hasCourse {
                Text("Əvvəlcə kursu seçin")
                    .foregroundStyle(.secondary)
            } else if viewModel.availableMentors.isEmpty {
                Text("Bu kurs üçün mentor yoxdur")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.availableMentors) { mentor in
                    Button {
                        viewModel.toggleMentor(mentor)
                    } label: {
                        HStack {
                            Text(mentor.fullName)
                                .foregroundStyle(.textPrimary)

                            Spacer()

                            if viewModel.isMentorSelected(mentor) {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .accessibilityIdentifier("mentor_row_\(mentor.id)")
                }
            }
        }
    }
}
