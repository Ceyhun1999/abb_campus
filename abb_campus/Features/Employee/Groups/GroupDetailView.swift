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
            List {
                infoSection(detail.group)

                Section {
                    Button {
                        viewModel.showImport()
                    } label: {
                        Label("Excel-dən tələbə idxal et", systemImage: "square.and.arrow.down")
                    }
                    .accessibilityIdentifier("import_students_button")
                }

                studentsSection(detail.students)
            }
            .font(.manropeRegular(16))
            .refreshable {
                await viewModel.load()
            }
        }
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
                GroupFormView(viewModel: editViewModel) {
                    Task {
                        await viewModel.groupSaved()
                    }
                }
            }
        }
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

    // MARK: - Info

    private func infoSection(_ group: StudyGroup) -> some View {
        Section {
            LabeledContent("Kurs", value: group.course?.name ?? "—")
            LabeledContent("Status") {
                Text(group.isActive ? "Aktiv" : "Bitib")
                    .foregroundStyle(group.isActive ? .green : .red)
            }
            LabeledContent("Müəllim", value: group.teacher?.fullName ?? "Təyin edilməyib")
            LabeledContent("Mentorlar", value: mentorNames(group))
            LabeledContent("Müddət", value: period(group))
            LabeledContent("Tələbə sayı", value: "\(group.studentsCount ?? 0)")
        }
    }

    private func mentorNames(_ group: StudyGroup) -> String {
        let names = group.mentors?.map(\.fullName) ?? []
        return names.isEmpty ? "Təyin edilməyib" : names.joined(separator: "\n")
    }

    private func period(_ group: StudyGroup) -> String {
        let start = DateFormatting.displayDate(from: group.startDate) ?? "—"
        let end = DateFormatting.displayDate(from: group.endDate) ?? "…"

        return "\(start) – \(end)"
    }

    // MARK: - Students

    private func studentsSection(_ students: [GroupStudent]) -> some View {
        Section("Tələbələr (\(students.count))") {
            if students.isEmpty {
                ContentUnavailableView(
                    "Qrupda tələbə yoxdur",
                    systemImage: "person.3",
                    description: Text("Tələbələri Excel faylından idxal edin.")
                )
            } else {
                ForEach(students) { student in
                    PersonRow(firstName: student.firstName, lastName: student.lastName, subtitle: student.email)
                }
            }
        }
    }
}
