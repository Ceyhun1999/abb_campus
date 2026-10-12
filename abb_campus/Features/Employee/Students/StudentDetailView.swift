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

                    ErrorMessageText(
                        message: viewModel.actionErrorMessage,
                        accessibilityID: "student_status_error"
                    )

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

    @ViewBuilder
    private func statusButton(_ student: DirectoryStudent) -> some View {
        if student.isActive {
            Button {
                viewModel.requestStatusChange()
            } label: {
                Group {
                    if viewModel.isUpdatingStatus {
                        ProgressView()
                    } else {
                        Text(viewModel.statusActionTitle)
                            .font(.manropeSemiBold(17))
                    }
                }
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isUpdatingStatus)
            .accessibilityIdentifier("student_status_button")
        } else {
            PrimaryButton(
                title: viewModel.statusActionTitle,
                isLoading: viewModel.isUpdatingStatus
            ) {
                viewModel.requestStatusChange()
            }
            .accessibilityIdentifier("student_status_button")
        }
    }
}

struct SummaryCard: View {

    let icon: String
    let title: String
    let value: String
    var tint: Color = .blue

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manropeRegular(12))
                    .foregroundStyle(.textSecondary)

                Text(value)
                    .font(.manropeSemiBold(15))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .cardStyle(cornerRadius: 16)
    }
}
