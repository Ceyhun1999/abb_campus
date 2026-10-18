import SwiftUI

struct StudentDetailView: View {

    @Environment(\.dismiss) private var dismiss
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

                    deleteButton
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
            viewModel.deleteConfirmationTitle,
            isPresented: $viewModel.isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Tələbəni sil", role: .destructive) {
                Task {
                    await viewModel.delete()
                }
            }
            .accessibilityIdentifier("confirm_delete_student")

            Button("Ləğv et", role: .cancel) {}
        }
        .onChange(of: viewModel.isDeleted) { _, isDeleted in
            if isDeleted {
                dismiss()
            }
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

            SummaryCard(icon: "book.fill", title: "Kurs", value: student.group?.courseName ?? "—", tint: .indigo)
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        StatusActionButton(title: "Tələbəni sil", isActive: true, isLoading: viewModel.isDeleting) {
            viewModel.requestDelete()
        }
        .accessibilityIdentifier("delete_student_button")
    }
}
