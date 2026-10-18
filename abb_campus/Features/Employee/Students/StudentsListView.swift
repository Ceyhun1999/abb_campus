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

            if let courseName = viewModel.courseFilterName {
                FilterChip(title: courseName) {
                    viewModel.courseFilterId = nil
                }
            }

            AsyncContentView(
                state: viewModel.state,
                isEmpty: \.isEmpty,
                emptyTitle: "Tələbə tapılmadı",
                emptyMessage: viewModel.emptyMessage,
                emptyIcon: "person.crop.circle.badge.questionmark",
                retry: viewModel.load
            ) { students in
                List {
                    ForEach(students) { student in
                        NavigationLink(value: student) {
                            StudentRow(student: student)
                        }
                        .accessibilityIdentifier("student_row_\(student.id)")
                        .onAppear {
                            Task {
                                await viewModel.loadMoreIfNeeded(student)
                            }
                        }
                    }

                    LoadMoreIndicator(isLoading: viewModel.isLoadingMore)
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                courseMenu
            }
        }
        .task {
            await viewModel.loadCourses()
        }
        .task(id: viewModel.query) {
            await viewModel.queryChanged()
        }
    }

    // MARK: - Course Filter

    private var courseMenu: some View {
        @Bindable var viewModel = viewModel

        return CourseFilterMenu(selection: $viewModel.courseFilterId, courses: viewModel.courses)
            .accessibilityIdentifier("student_course_filter")
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

                Text(student.groupSubtitle)
                    .font(.manropeRegular(13))
                    .foregroundStyle(.textSecondary)
                    .lineLimit(1)
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
