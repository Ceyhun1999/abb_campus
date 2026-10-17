import SwiftUI

struct GroupsListView: View {

    @State private var viewModel: GroupsListViewModel

    init(viewModel: GroupsListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            SearchField(prompt: "Qrup adı üzrə axtar", text: $viewModel.searchText)
                .disabled(!viewModel.isSearchEnabled)
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.bottom, 8)
                .accessibilityIdentifier("group_search_field")

            if let courseName = viewModel.courseFilterName {
                FilterChip(title: courseName) {
                    viewModel.courseFilterId = nil
                }
            }

            groupList
        }
        .background(.appBackground)
        .navigationTitle("Qruplar")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                courseMenu
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showCreateGroup()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Yeni qrup")
            }
        }
        .sheet(isPresented: $viewModel.isCreateGroupPresented, onDismiss: {
            Task {
                await viewModel.createSheetDismissed()
            }
        }) {
            if let createGroupViewModel = viewModel.createGroupViewModel {
                GroupFormView(viewModel: createGroupViewModel) { group in
                    viewModel.groupCreated(group)
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.isCreatedGroupPresented) {
            if let createdGroupViewModel = viewModel.createdGroupViewModel {
                GroupDetailView(viewModel: createdGroupViewModel)
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

        return Menu {
            Picker("Kurs", selection: $viewModel.courseFilterId) {
                Text("Bütün kurslar").tag(Int?.none)

                ForEach(viewModel.courses) { course in
                    Text(course.name).tag(Optional(course.id))
                }
            }
        } label: {
            Image(systemName: viewModel.courseFilterId == nil
                  ? "line.3.horizontal.decrease.circle"
                  : "line.3.horizontal.decrease.circle.fill")
        }
        .disabled(!viewModel.isCourseFilterEnabled)
        .accessibilityLabel("Kurs filtri")
        .accessibilityIdentifier("group_course_filter")
    }

    // MARK: - List

    private var groupList: some View {
        AsyncContentView(
            state: viewModel.state,
            isEmpty: \.isEmpty,
            emptyTitle: "Qrup tapılmadı",
            emptyMessage: viewModel.emptyMessage,
            emptyIcon: "square.grid.2x2",
            retry: viewModel.load
        ) { groups in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(groups) { group in
                        NavigationLink(value: group) {
                            GroupCardRow(group: group)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("group_row_\(group.id)")
                    }
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 12)
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .refreshingIndicator(viewModel.isRefreshing)
    }
}
