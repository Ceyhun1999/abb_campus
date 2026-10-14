import SwiftUI

struct StudentsListView: View {

    @State private var viewModel: StudentsListViewModel

    init(viewModel: StudentsListViewModel) {
        _viewModel = State(initialValue: viewModel)
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
                        PersonRow(
                            firstName: student.firstName,
                            lastName: student.lastName,
                            subtitle: student.group?.name ?? "Qrupsuz"
                        ) {
                            if !student.isActive {
                                Text("Deaktiv")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .accessibilityIdentifier("student_row_\(student.id)")
                }
                .listStyle(.plain)
                .font(.manropeRegular(16))
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
        .task(id: viewModel.query) {
            await viewModel.queryChanged()
        }
    }
}
