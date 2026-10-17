import SwiftUI

struct EmployeeHomeView: View {

    @Environment(AuthenticationState.self) private var authenticationState

    @State private var viewModel: EmployeeHomeViewModel

    init(viewModel: EmployeeHomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(state: viewModel.state, retry: viewModel.load) { summary in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerView

                    AcademyInfoCard()

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
            DashboardTile(
                icon: "chart.bar.fill",
                tint: .green,
                title: "Aktiv tələbə",
                value: summary.activeStudentsCount
            )

            DashboardTile(
                icon: "person.2.fill",
                tint: .blue,
                title: "Müəllimlər",
                value: summary.teachersCount
            )

            DashboardTile(
                icon: "square.grid.2x2.fill",
                tint: .indigo,
                title: "Qruplar",
                value: summary.groupsCount
            )

            DashboardTile(
                icon: "megaphone.fill",
                tint: .red,
                title: "Elanlar",
                value: summary.announcementsCount
            )
        }
    }

    // MARK: - Announcements

    private func recentAnnouncements(_ announcements: [Announcement]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Son elanlar")
                    .font(.manropeBold(20))
                    .foregroundStyle(.textPrimary)

                Spacer()

                NavigationLink(value: EmployeeRoute.announcements) {
                    HStack(spacing: 4) {
                        Text("Hamısı")

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .font(.manropeSemiBold(15))
                }
                .accessibilityIdentifier("all_announcements_button")
            }

            if announcements.isEmpty {
                Text("Hələ elan yoxdur. Yeni elan yaratmaq üçün «Hamısı» bölməsinə keçin.")
                    .font(.manropeRegular(15))
                    .foregroundStyle(.textSecondary)
            } else {
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

private struct AcademyInfoCard: View {

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("ABB Tech Academy")
                    .font(.manropeBold(22))
                    .foregroundStyle(.white)

                Text("Proqramlaşdırma, dizayn və data üzrə peşəkar IT təhsili")
                    .font(.manropeRegular(14))
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "graduationcap.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(.white.opacity(0.18))
                .clipShape(Circle())
        }
        .padding(20)
        .background(.brandBlue)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("academy_card")
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
