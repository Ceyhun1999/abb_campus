import SwiftUI

struct TeacherDetailView: View {

    @State private var viewModel: TeacherDetailViewModel

    init(viewModel: TeacherDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        AsyncContentView(state: viewModel.state, retry: viewModel.load) { teacher in
            List {
                PersonHeader(
                    firstName: teacher.firstName,
                    lastName: teacher.lastName,
                    subtitle: teacher.positionTitle
                )

                Section {
                    LabeledContent("İxtisas", value: teacher.specialty ?? "—")
                    LabeledContent("Status") {
                        Text(teacher.isActive ? "Aktiv" : "Deaktiv")
                            .foregroundStyle(teacher.isActive ? .green : .red)
                    }
                }

                Section("Əlaqə") {
                    LabeledContent("E-poçt", value: teacher.email)
                    LabeledContent("Telefon", value: teacher.phone ?? "—")
                }

                groupsSection(teacher.groups ?? [])

                Section {
                    StatusToggleButton(
                        title: viewModel.statusActionTitle,
                        isActive: teacher.isActive,
                        isLoading: viewModel.isUpdatingStatus,
                        action: viewModel.requestStatusChange
                    )
                    .accessibilityIdentifier("teacher_status_button")
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
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Groups

    private func groupsSection(_ groups: [StudyGroup]) -> some View {
        Section("Qruplar (\(groups.count))") {
            if groups.isEmpty {
                Text("Bu müəllimə hələ qrup təyin edilməyib.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(groups) { group in
                    NavigationLink(value: group) {
                        GroupRow(group: group)
                    }
                }
            }
        }
    }
}
