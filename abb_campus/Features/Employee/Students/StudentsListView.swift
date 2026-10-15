import SwiftUI

struct StudentsListView: View {

    @State private var viewModel: StudentsListViewModel
    @Binding private var filterRequest: StudentStatusFilter?

    init(viewModel: StudentsListViewModel, filterRequest: Binding<StudentStatusFilter?> = .constant(nil)) {
        _viewModel = State(initialValue: viewModel)
        _filterRequest = filterRequest
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            Picker("Status", selection: $viewModel.statusFilter) {
                ForEach(StudentStatusFilter.allCases) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.bottom, 8)
            .accessibilityIdentifier("student_status_filter")

            AsyncContentView(
                state: viewModel.state,
                isEmpty: \.isEmpty,
                emptyTitle: "Tələbə tapılmadı",
                emptyMessage: viewModel.emptyMessage,
                emptyIcon: "person.crop.circle.badge.questionmark",
                retry: viewModel.load
            ) { students in
                List(students) { student in
                    NavigationLink(value: student) {
                        StudentRow(student: student)
                    }
                    .accessibilityIdentifier("student_row_\(student.id)")
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.load()
                }
            }
            .refreshingIndicator(viewModel.isRefreshing)
        }
        .navigationTitle("Tələbələr")
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Ad, soyad və ya qrup üzrə axtar"
        )
        .onChange(of: filterRequest, initial: true) { _, filter in
            if let filter {
                viewModel.statusFilter = filter
                filterRequest = nil
            }
        }
        .task(id: viewModel.query) {
            await viewModel.queryChanged()
        }
    }
}

// MARK: - Student Row

private struct StudentRow: View {

    let student: DirectoryStudent

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(firstName: student.firstName, lastName: student.lastName)

            VStack(alignment: .leading, spacing: 3) {
                Text(student.fullName)
                    .font(.manropeSemiBold(16))
                    .foregroundStyle(.textPrimary)

                Text(student.group?.name ?? "Qrupsuz")
                    .font(.manropeRegular(13))
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            Circle()
                .fill(student.isActive ? Color.green : Color.red)
                .frame(width: 9, height: 9)
                .accessibilityLabel(student.isActive ? "Aktiv" : "Deaktiv")
        }
        .padding(.vertical, 4)
    }
}
