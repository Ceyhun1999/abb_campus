import SwiftUI

struct StudentDetailView: View {

    @State private var viewModel: StudentDetailViewModel

    init(viewModel: StudentDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        AsyncContentView(state: viewModel.state, retry: viewModel.load) { student in
            List {
                PersonHeader(
                    firstName: student.firstName,
                    lastName: student.lastName,
                    subtitle: "Tələbə",
                    nameAccessibilityID: "student_detail_name"
                )

                Section {
                    LabeledContent("Qrup", value: student.group?.name ?? "—")
                    LabeledContent("Status") {
                        Text(student.isActive ? "Aktiv" : "Deaktiv")
                            .foregroundStyle(student.isActive ? .green : .red)
                    }
                }

                Section("Əlaqə") {
                    LabeledContent("E-poçt", value: student.email)
                    LabeledContent("Telefon", value: student.phone ?? "—")
                    LabeledContent(
                        "Qeydiyyat tarixi",
                        value: DateFormatting.displayDate(from: student.createdAt) ?? "—"
                    )
                }

                Section {
                    StatusToggleButton(
                        title: viewModel.statusActionTitle,
                        isActive: student.isActive,
                        isLoading: viewModel.isUpdatingStatus,
                        action: viewModel.requestStatusChange
                    )
                    .accessibilityIdentifier("student_status_button")
                }
            }
            .font(.manropeRegular(16))
            .refreshable {
                await viewModel.load()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .errorAlert(viewModel.actionErrorMessage, onDismiss: viewModel.dismissError)
        .confirmationDialog(
            viewModel.statusConfirmationTitle,
            isPresented: $viewModel.isStatusConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(viewModel.statusActionTitle, role: .destructive) {
                Task {
                    await viewModel.toggleStatus()
                }
            }

            Button("Ləğv et", role: .cancel) {}
        }
    }
}
