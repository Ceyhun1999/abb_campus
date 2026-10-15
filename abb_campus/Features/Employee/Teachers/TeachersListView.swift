import SwiftUI

struct TeachersListView: View {

    @State private var viewModel: TeachersListViewModel

    init(viewModel: TeachersListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            Picker("Vəzifə", selection: $viewModel.positionFilter) {
                ForEach(TeacherPositionFilter.allCases) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.bottom, 8)
            .accessibilityIdentifier("teacher_position_filter")

            if let specialty = viewModel.specialtyFilter {
                FilterChip(title: specialty) {
                    viewModel.specialtyFilter = nil
                }
            }

            teacherList
        }
        .background(.appBackground)
        .navigationTitle("Müəllimlər")
        .searchable(text: $viewModel.searchText, prompt: "Ad və ya ixtisas üzrə axtar")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                specialtyMenu
            }
        }
        .task {
            await viewModel.loadSpecialties()
        }
        .task(id: viewModel.query) {
            await viewModel.queryChanged()
        }
    }

    // MARK: - Specialty

    private var specialtyMenu: some View {
        @Bindable var viewModel = viewModel

        return Menu {
            Picker("İxtisas", selection: $viewModel.specialtyFilter) {
                Text("Bütün ixtisaslar").tag(String?.none)

                ForEach(viewModel.specialties, id: \.self) { specialty in
                    Text(specialty).tag(Optional(specialty))
                }
            }
        } label: {
            Image(systemName: viewModel.hasSpecialtyFilter
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
        }
        .accessibilityLabel("İxtisas filtri")
        .accessibilityIdentifier("teacher_specialty_filter")
    }

    // MARK: - List

    private var teacherList: some View {
        AsyncContentView(
            state: viewModel.state,
            isEmpty: \.isEmpty,
            emptyTitle: "Müəllim tapılmadı",
            emptyMessage: viewModel.emptyMessage,
            emptyIcon: "person.crop.circle.badge.questionmark",
            retry: viewModel.load
        ) { teachers in
            List(teachers) { teacher in
                NavigationLink(value: teacher) {
                    HStack(spacing: 14) {
                        AvatarView(firstName: teacher.firstName, lastName: teacher.lastName)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 8) {
                                Text(teacher.fullName)
                                    .font(.manropeSemiBold(16))
                                    .foregroundStyle(.textPrimary)

                                PositionBadge(position: teacher.position ?? .teacher)

                                if !teacher.isActive {
                                    Text("Deaktiv")
                                        .font(.manropeSemiBold(11))
                                        .foregroundStyle(.red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.red.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }

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
        .refreshingIndicator(viewModel.isRefreshing)
    }
}

// MARK: - Position Badge

struct PositionBadge: View {

    let position: TeacherPosition

    var body: some View {
        Text(position.title)
            .font(.manropeSemiBold(11))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }

    private var tint: Color {
        position == .mentor ? .purple : .blue
    }
}
