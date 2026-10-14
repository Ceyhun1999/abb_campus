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
                specialtyChip(specialty)
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

    private func specialtyChip(_ specialty: String) -> some View {
        HStack {
            Button {
                viewModel.specialtyFilter = nil
            } label: {
                HStack(spacing: 6) {
                    Text(specialty)
                        .lineLimit(1)

                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                }
                .font(.manropeSemiBold(13))
                .foregroundStyle(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.12))
                .clipShape(Capsule())
            }
            .accessibilityLabel("\(specialty) filtrini sil")

            Spacer()
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
        .padding(.bottom, 8)
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
    }
}

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
