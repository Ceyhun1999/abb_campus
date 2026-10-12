import SwiftUI

struct GroupDetailView: View {

    @Environment(\.dependencies) private var dependencies

    @State private var viewModel: GroupDetailViewModel

    init(viewModel: GroupDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        AsyncContentView(state: viewModel.state, retry: viewModel.load) { detail in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    infoCard(detail.group)

                    PrimaryButton(title: "Excel-dən tələbə idxal et") {
                        viewModel.showImport()
                    }
                    .accessibilityIdentifier("import_students_button")

                    studentsSection(detail.students)
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 20)
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .background(.appBackground)
        .navigationTitle(viewModel.group.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.isImportPresented) {
            StudentImportView(
                viewModel: StudentImportViewModel(
                    group: viewModel.group,
                    groupService: dependencies.groupService
                )
            )
        }
        .onChange(of: viewModel.isImportPresented) { _, isPresented in
            if !isPresented {
                Task {
                    await viewModel.load()
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func infoCard(_ group: StudyGroup) -> some View {
        InfoCard {
            HStack {
                InfoRow(icon: "book", title: "Kurs", value: group.course?.name ?? "—")

                StatusBadge(isActive: group.isActive, inactiveTitle: "Bitib")
                    .padding(.trailing, 16)
            }
            InfoDivider()
            InfoRow(icon: "person", title: "Müəllim", value: group.teacher?.fullName ?? "Təyin edilməyib")
            InfoDivider()
            InfoRow(icon: "calendar", title: "Müddət", value: period(group))
            InfoDivider()
            InfoRow(icon: "person.3", title: "Tələbə sayı", value: "\(group.studentsCount ?? 0)")
        }
    }

    private func period(_ group: StudyGroup) -> String {
        let start = DateFormatting.displayDate(from: group.startDate) ?? "—"
        let end = DateFormatting.displayDate(from: group.endDate) ?? "…"

        return "\(start) – \(end)"
    }

    @ViewBuilder
    private func studentsSection(_ students: [GroupStudent]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tələbələr (\(students.count))")
                .font(.manropeBold(20))
                .foregroundStyle(.textPrimary)

            if students.isEmpty {
                ContentUnavailableView(
                    "Qrupda tələbə yoxdur",
                    systemImage: "person.3",
                    description: Text("Tələbələri Excel faylından idxal edin.")
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(students) { student in
                        HStack(spacing: 12) {
                            AvatarView(firstName: student.firstName, lastName: student.lastName, size: 38)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(student.fullName)
                                    .font(.manropeSemiBold(15))
                                    .foregroundStyle(.textPrimary)

                                Text(student.email)
                                    .font(.manropeRegular(12))
                                    .foregroundStyle(.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        if student.id != students.last?.id {
                            InfoDivider()
                        }
                    }
                }
                .cardStyle()
            }
        }
    }
}
