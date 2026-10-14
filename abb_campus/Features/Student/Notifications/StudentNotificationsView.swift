import SwiftUI

struct StudentNotificationsView: View {

    @State private var viewModel: StudentNotificationsViewModel

    init(viewModel: StudentNotificationsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(
            state: viewModel.state,
            isEmpty: \.isEmpty,
            emptyTitle: "Bildiriş yoxdur",
            emptyMessage: "Yeni elanlar burada görünəcək.",
            emptyIcon: "bell",
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
        .navigationTitle("Bildirişlər")
        .task {
            await viewModel.load()
        }
    }
}
