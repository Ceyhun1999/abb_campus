import SwiftUI

struct AnnouncementsListView: View {

    @Environment(\.dependencies) private var dependencies

    @State private var viewModel: AnnouncementsListViewModel

    init(viewModel: AnnouncementsListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        AsyncContentView(
            state: viewModel.state,
            isEmpty: \.isEmpty,
            emptyTitle: "Elan yoxdur",
            emptyMessage: "İlk elanı dərc etmək üçün + düyməsinə toxunun.",
            emptyIcon: "megaphone",
            retry: viewModel.load
        ) { announcements in
            List(announcements) { announcement in
                NavigationLink(value: announcement) {
                    AnnouncementRow(announcement: announcement)
                        .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.load()
            }
        }
        .navigationTitle("Elanlar")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showCreate()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Yeni elan")
                .accessibilityIdentifier("new_announcement_button")
            }
        }
        .sheet(isPresented: $viewModel.isCreatePresented) {
            NewAnnouncementView(
                viewModel: NewAnnouncementViewModel(
                    announcementService: dependencies.announcementService,
                    groupService: dependencies.groupService
                )
            ) {
                Task {
                    await viewModel.announcementCreated()
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
