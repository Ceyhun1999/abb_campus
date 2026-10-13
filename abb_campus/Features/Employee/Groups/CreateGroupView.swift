import SwiftUI

struct CreateGroupView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: CreateGroupViewModel

    let onCreated: () -> Void

    init(viewModel: CreateGroupViewModel, onCreated: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onCreated = onCreated
    }

    var body: some View {
        NavigationStack {
            AsyncContentView(state: viewModel.options, retry: viewModel.loadOptions) { options in
                form(options)
            }
            .navigationTitle("Yeni qrup")
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
                        Button("Yarat") {
                            Task {
                                if await viewModel.save() != nil {
                                    onCreated()
                                }
                            }
                        }
                        .disabled(viewModel.options.value == nil)
                        .accessibilityIdentifier("create_group_save")
                    }
                }
            }
        }
        .task {
            await viewModel.loadOptions()
        }
    }

    private func form(_ options: CreateGroupOptions) -> some View {
        @Bindable var viewModel = viewModel

        return Form {
            Section("Qrup") {
                TextField("Qrup adı, məs. IOS-03", text: $viewModel.name)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("create_group_name")

                Picker("Kurs", selection: $viewModel.selectedCourseId) {
                    ForEach(options.courses) { course in
                        Text(course.name).tag(Optional(course.id))
                    }
                }
                .pickerStyle(.navigationLink)

                Picker("Müəllim", selection: $viewModel.selectedTeacherId) {
                    Text("Təyin edilməyib").tag(Int?.none)

                    ForEach(options.teachers) { teacher in
                        Text(teacher.fullName).tag(Optional(teacher.id))
                    }
                }
                .pickerStyle(.navigationLink)
            }

            Section("Müddət") {
                DatePicker("Başlama tarixi", selection: $viewModel.startDate, displayedComponents: .date)

                Toggle("Bitmə tarixi var", isOn: $viewModel.hasEndDate)

                if viewModel.hasEndDate {
                    DatePicker("Bitmə tarixi", selection: $viewModel.endDate, displayedComponents: .date)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    ErrorMessageText(message: errorMessage, accessibilityID: "create_group_error")
                }
            }
        }
    }
}
