import SwiftUI

struct GroupsListView: View {

    @State private var viewModel: GroupsListViewModel

    init(viewModel: GroupsListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        AsyncContentView(
            state: viewModel.state,
            isEmpty: \.isEmpty,
            emptyTitle: "Qrup tapılmadı",
            emptyMessage: "Yeni qrup yaratmaq üçün + düyməsinə toxunun.",
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
        .background(.appBackground)
        .navigationTitle("Qruplar")
        .searchable(text: $viewModel.searchText, prompt: "Qrup adı üzrə axtar")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showCreateGroup()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Yeni qrup")
            }
        }
        .sheet(isPresented: $viewModel.isCreateGroupPresented) {
            if let createGroupViewModel = viewModel.createGroupViewModel {
                GroupFormView(viewModel: createGroupViewModel) {
                    Task {
                        await viewModel.groupCreated()
                    }
                }
            }
        }
        .task(id: viewModel.searchText) {
            await viewModel.queryChanged()
        }
    }
}
