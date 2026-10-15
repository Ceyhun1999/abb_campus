import SwiftUI

struct EmployeeHomeView: View {

    @Environment(AuthenticationState.self) private var authenticationState

    @State private var viewModel: EmployeeHomeViewModel

    private let onOpenStudents: (StudentStatusFilter) -> Void
    private let onOpenTab: (EmployeeTab) -> Void

    init(
        viewModel: EmployeeHomeViewModel,
        onOpenStudents: @escaping (StudentStatusFilter) -> Void = { _ in },
        onOpenTab: @escaping (EmployeeTab) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onOpenStudents = onOpenStudents
        self.onOpenTab = onOpenTab
    }

    var body: some View {
        AsyncContentView(state: viewModel.state, retry: viewModel.load) { summary in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerView

                    Button {
                        onOpenStudents(.all)
                    } label: {
                        TotalStudentsCard(
                            count: summary.studentsCount,
                            newThisMonth: summary.newStudentsThisMonth
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("total_students_card")

                    statisticsGrid(summary)

                    recentAnnouncements(summary.recentAnnouncements)
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 20)
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .background(.appBackground)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greeting)
                    .font(.manropeBold(24))
                    .foregroundStyle(.textPrimary)
                    .accessibilityIdentifier("employee_greeting")

                Text("Bugünkü icmalı nəzərdən keçirin")
                    .font(.manropeRegular(15))
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            if let user = authenticationState.currentUser {
                AvatarView(firstName: user.firstName, lastName: user.lastName, size: 52)
            }
        }
    }

    // MARK: - Statistics

    private func statisticsGrid(_ summary: DashboardSummary) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
            spacing: 14
        ) {
            Button {
                onOpenStudents(.active)
            } label: {
                DashboardTile(
                    icon: "chart.bar.fill",
                    tint: .green,
                    title: "Aktiv tələbə",
                    value: summary.activeStudentsCount,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("active_students_tile")

            NavigationLink(value: EmployeeRoute.teachers) {
                DashboardTile(
                    icon: "person.2.fill",
                    tint: .blue,
                    title: "Müəllimlər",
                    value: summary.teachersCount,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("teachers_tile")

            Button {
                onOpenTab(.groups)
            } label: {
                DashboardTile(
                    icon: "square.grid.2x2.fill",
                    tint: .indigo,
                    title: "Qruplar",
                    value: summary.groupsCount,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("groups_tile")

            Button {
                onOpenTab(.announcements)
            } label: {
                DashboardTile(
                    icon: "megaphone.fill",
                    tint: .red,
                    title: "Elanlar",
                    value: summary.announcementsCount,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("announcements_tile")
        }
    }

    // MARK: - Announcements

    @ViewBuilder
    private func recentAnnouncements(_ announcements: [Announcement]) -> some View {
        if !announcements.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Son elanlar")
                    .font(.manropeBold(20))
                    .foregroundStyle(.textPrimary)

                VStack(spacing: 0) {
                    ForEach(announcements) { announcement in
                        NavigationLink(value: announcement) {
                            AnnouncementRow(announcement: announcement)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)

                        if announcement.id != announcements.last?.id {
                            InfoDivider()
                        }
                    }
                }
                .cardStyle()
            }
        }
    }
}

private struct TotalStudentsCard: View {

    let count: Int
    let newThisMonth: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Ümumi tələbə sayı")
                    .font(.manropeRegular(15))
                    .foregroundStyle(.white.opacity(0.85))

                Text("\(count)")
                    .font(.manropeBold(36))
                    .foregroundStyle(.white)
                    .accessibilityIdentifier("total_students_count")

                Text("+\(newThisMonth) bu ay")
                    .font(.manropeSemiBold(14))
                    .foregroundStyle(.white.opacity(0.9))
            }

            Spacer()

            Image(systemName: "person.3.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(.white.opacity(0.18))
                .clipShape(Circle())
        }
        .padding(20)
        .background(.brandBlue)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

private struct DashboardTile: View {

    let icon: String
    let tint: Color
    let title: String
    let value: Int
    var showsChevron = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manropeRegular(14))
                    .foregroundStyle(.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("\(value)")
                    .font(.manropeBold(20))
                    .foregroundStyle(.textPrimary)
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(cornerRadius: 18)
    }
}
