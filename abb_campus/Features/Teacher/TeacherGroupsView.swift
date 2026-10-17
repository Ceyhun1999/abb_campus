import SwiftUI

struct TeacherGroupsView: View {

    @State private var viewModel: TeacherGroupsViewModel

    init(viewModel: TeacherGroupsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(
            state: viewModel.state,
            isEmpty: { $0.isEmpty },
            emptyTitle: "Qrup yoxdur",
            emptyMessage: "Sizi qrupa müəllim və ya mentor kimi təyin etdikdə qrup burada görünəcək.",
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
                        .accessibilityIdentifier("teacher_group_row_\(group.id)")
                    }
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 12)
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .background(.appBackground)
        .navigationTitle("Qruplarım")
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - Group Detail

struct TeacherGroupDetailView: View {

    @State private var viewModel: TeacherGroupDetailViewModel

    init(viewModel: TeacherGroupDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                InfoCard {
                    HStack {
                        InfoRow(icon: "book", title: "Kurs", value: viewModel.group.course?.name ?? "—")

                        StatusBadge(isActive: viewModel.group.isActive, inactiveTitle: "Bitib")
                            .padding(.trailing, 16)
                    }
                }

                VStack(spacing: 0) {
                    ForEach(Array(viewModel.routes.enumerated()), id: \.offset) { index, item in
                        NavigationLink(value: item.route) {
                            HStack(spacing: 0) {
                                InfoRow(icon: item.icon, title: item.subtitle, value: item.title)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.trailing, 16)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("teacher_route_\(index)")

                        if index < viewModel.routes.count - 1 {
                            InfoDivider()
                        }
                    }
                }
                .cardStyle()

                switch viewModel.state {
                case .loaded(let students):
                    GroupStudentsSection(students: students, emptyMessage: "Qrupa hələ tələbə əlavə olunmayıb.")
                case .failed(let message):
                    Text(message)
                        .font(.manropeRegular(14))
                        .foregroundStyle(.red)
                default:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.vertical, 20)
        }
        .refreshable {
            await viewModel.load()
        }
        .background(.appBackground)
        .navigationTitle(viewModel.group.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }
}
