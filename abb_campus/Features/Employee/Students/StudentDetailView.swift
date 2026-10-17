import SwiftUI

struct StudentDetailView: View {

    @State private var viewModel: StudentDetailViewModel

    init(viewModel: StudentDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        AsyncContentView(state: viewModel.state, retry: viewModel.load) { student in
            ScrollView {
                VStack(spacing: 20) {
                    header(student)

                    summaryCards(student)

                    InfoCard {
                        InfoRow(icon: "envelope", title: "E-poçt", value: student.email)
                        InfoDivider()
                        InfoRow(icon: "phone", title: "Telefon", value: student.phone ?? "—")
                        InfoDivider()
                        InfoRow(
                            icon: "calendar",
                            title: "Qeydiyyat tarixi",
                            value: DateFormatting.displayDate(from: student.createdAt) ?? "—"
                        )
                    }

                    statusButton(student)
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
    }

    // MARK: - Header

    private func header(_ student: DirectoryStudent) -> some View {
        VStack(spacing: 10) {
            AvatarView(firstName: student.firstName, lastName: student.lastName, size: 96)

            Text(student.fullName)
                .font(.manropeBold(22))
                .foregroundStyle(.textPrimary)
                .accessibilityIdentifier("student_detail_name")

            Text("Tələbə")
                .font(.manropeRegular(15))
                .foregroundStyle(.textSecondary)
        }
    }

    // MARK: - Summary

    private func summaryCards(_ student: DirectoryStudent) -> some View {
        HStack(spacing: 12) {
            SummaryCard(icon: "square.grid.2x2.fill", title: "Qrup", value: student.group?.name ?? "—")

            SummaryCard(
                icon: student.isActive ? "checkmark.circle.fill" : "xmark.circle.fill",
                title: "Status",
                value: student.isActive ? "Aktiv" : "Deaktiv",
                tint: student.isActive ? .green : .red
            )
        }
    }

    // MARK: - Status

    private func statusButton(_ student: DirectoryStudent) -> some View {
        StatusActionButton(
            title: viewModel.statusActionTitle,
            isActive: student.isActive,
            isLoading: viewModel.isUpdatingStatus
        ) {
            viewModel.requestStatusChange()
        }
        .accessibilityIdentifier("student_status_button")
    }
}
