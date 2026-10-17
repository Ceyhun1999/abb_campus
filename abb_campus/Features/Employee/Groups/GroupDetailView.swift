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
                    .disabled(!detail.group.isActive)
                    .opacity(detail.group.isActive ? 1 : 0.5)
                    .accessibilityIdentifier("import_students_button")

                    if !detail.group.isActive {
                        Text("Qrup bitib. Bitmiş qrupa tələbə idxal etmək olmaz.")
                            .font(.manropeRegular(14))
                            .foregroundStyle(.textSecondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }

                    scheduleButton

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
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Redaktə et") {
                    viewModel.showEdit()
                }
                .disabled(viewModel.state.value == nil)
                .accessibilityIdentifier("edit_group_button")
            }
        }
        .sheet(isPresented: $viewModel.isEditPresented) {
            if let editViewModel = viewModel.editViewModel {
                GroupFormView(viewModel: editViewModel) { _ in
                    Task {
                        await viewModel.groupSaved()
                    }
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.isSchedulePresented) {
            GroupScheduleView(
                viewModel: GroupScheduleViewModel(
                    group: viewModel.scheduleGroup,
                    scheduleSource: dependencies.groupService,
                    lessonService: dependencies.lessonService,
                    scheduleImporter: dependencies.groupService
                )
            )
        }
        .navigationDestination(isPresented: $viewModel.isImportPresented) {
            GroupImportView(
                viewModel: GroupImportViewModel(
                    group: viewModel.group,
                    groupService: dependencies.groupService
                )
            )
        }
        .onChange(of: viewModel.isImportPresented) { _, isPresented in
            Task {
                await viewModel.importPresentationChanged(isPresented)
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Schedule

    private var scheduleButton: some View {
        Button {
            viewModel.showSchedule()
        } label: {
            InfoCard {
                HStack(spacing: 0) {
                    InfoRow(icon: "calendar", title: "Dərs cədvəli", value: "Bax və ya Excel-dən yüklə")

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 16)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("group_schedule_button")
    }

    // MARK: - Info

    private func infoCard(_ group: StudyGroup) -> some View {
        InfoCard {
            HStack {
                InfoRow(icon: "book", title: "Kurs", value: group.course?.name ?? "—")

                StatusBadge(isActive: group.isActive, inactiveTitle: "Bitib")
                    .padding(.trailing, 16)
            }
            InfoDivider()
            InfoRow(icon: "person", title: "Müəllim", value: group.teacher.map(staffName) ?? "Təyin edilməyib")
            InfoDivider()
            InfoRow(icon: "person.2", title: "Mentorlar", value: mentorNames(group))

            if !group.inactiveStaff.isEmpty {
                InfoDivider()
                Label(
                    "Qrupda deaktiv müəllim və ya mentor var. Qrupu redaktə edib başqasını təyin edin.",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.manropeRegular(14))
                .foregroundStyle(.red)
                .padding(16)
                .accessibilityIdentifier("inactive_staff_warning")
            }
            InfoDivider()
            InfoRow(icon: "calendar", title: "Müddət", value: period(group))
            InfoDivider()
            InfoRow(icon: "person.3", title: "Tələbə sayı", value: "\(group.studentsCount ?? 0)")
        }
    }

    // MARK: - Formatting

    private func mentorNames(_ group: StudyGroup) -> String {
        let names = group.mentors?.map(staffName) ?? []
        return names.isEmpty ? "Təyin edilməyib" : names.joined(separator: "\n")
    }

    private func staffName(_ person: StudyGroup.TeacherReference) -> String {
        person.isInactive ? "\(person.fullName) (deaktiv)" : person.fullName
    }

    private func period(_ group: StudyGroup) -> String {
        let start = DateFormatting.displayDate(from: group.startDate) ?? "—"
        let end = DateFormatting.displayDate(from: group.endDate) ?? "…"

        return "\(start) – \(end)"
    }

    // MARK: - Students

    @ViewBuilder
    private func studentsSection(_ students: [GroupStudent]) -> some View {
        GroupStudentsSection(students: students, emptyMessage: "Tələbələri Excel faylından idxal edin.")
    }
}
