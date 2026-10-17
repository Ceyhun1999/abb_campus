import SwiftUI

struct TeacherDetailView: View {

    @State private var viewModel: TeacherDetailViewModel

    init(viewModel: TeacherDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        AsyncContentView(state: viewModel.state, retry: viewModel.load) { teacher in
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        AvatarView(firstName: teacher.firstName, lastName: teacher.lastName, size: 96)

                        Text(teacher.fullName)
                            .font(.manropeBold(22))
                            .foregroundStyle(.textPrimary)

                        Text(teacher.positionTitle)
                            .font(.manropeRegular(15))
                            .foregroundStyle(.textSecondary)
                    }

                    InfoCard {
                        InfoRow(icon: "envelope", title: "E-poçt", value: teacher.email)
                        InfoDivider()
                        InfoRow(icon: "phone", title: "Telefon", value: teacher.phone ?? "—")
                        InfoDivider()
                        InfoRow(icon: "graduationcap", title: "İxtisas", value: teacher.specialty ?? "—")
                        InfoDivider()
                        InfoRow(
                            icon: teacher.isActive ? "checkmark.circle" : "xmark.circle",
                            title: "Status",
                            value: teacher.isActive ? "Aktiv" : "Deaktiv"
                        )
                    }

                    groupsSection(teacher.groups ?? [])

                    statusButton(teacher)
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 20)
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .background(.appBackground)
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

    // MARK: - Status

    private func statusButton(_ teacher: Teacher) -> some View {
        StatusActionButton(
            title: viewModel.statusActionTitle,
            isActive: teacher.isActive,
            isLoading: viewModel.isUpdatingStatus
        ) {
            viewModel.requestStatusChange()
        }
        .accessibilityIdentifier("teacher_status_button")
    }

    // MARK: - Groups


    @ViewBuilder
    private func groupsSection(_ groups: [StudyGroup]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Qruplar (\(groups.count))")
                .font(.manropeBold(20))
                .foregroundStyle(.textPrimary)

            if groups.isEmpty {
                Text("Bu müəllimə hələ qrup təyin edilməyib.")
                    .font(.manropeRegular(15))
                    .foregroundStyle(.textSecondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(groups) { group in
                        NavigationLink(value: group) {
                            GroupCardRow(group: group)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
