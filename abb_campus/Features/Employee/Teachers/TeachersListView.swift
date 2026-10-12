import SwiftUI

struct TeachersListView: View {

    @State private var viewModel: TeachersListViewModel

    init(viewModel: TeachersListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        AsyncContentView(
            state: viewModel.state,
            isEmpty: \.isEmpty,
            emptyTitle: "Müəllim tapılmadı",
            emptyIcon: "person.crop.circle.badge.questionmark",
            retry: viewModel.load
        ) { teachers in
            List(teachers) { teacher in
                NavigationLink(value: teacher) {
                    HStack(spacing: 14) {
                        AvatarView(firstName: teacher.firstName, lastName: teacher.lastName)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(teacher.fullName)
                                .font(.manropeSemiBold(16))
                                .foregroundStyle(.textPrimary)

                            Text(teacher.specialty ?? "İxtisas qeyd edilməyib")
                                .font(.manropeRegular(13))
                                .foregroundStyle(.textSecondary)
                        }

                        Spacer()

                        if let groupsCount = teacher.groupsCount {
                            Text("\(groupsCount) qrup")
                                .font(.manropeRegular(13))
                                .foregroundStyle(.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.load()
            }
        }
        .navigationTitle("Müəllimlər")
        .searchable(text: $viewModel.searchText, prompt: "Ad və ya ixtisas üzrə axtar")
        .task(id: viewModel.searchText) {
            await viewModel.queryChanged()
        }
    }
}
