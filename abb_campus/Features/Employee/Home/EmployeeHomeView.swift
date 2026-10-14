import SwiftUI

struct EmployeeHomeView: View {

    @Environment(AuthenticationState.self) private var authenticationState

    @State private var viewModel: EmployeeHomeViewModel

    init(viewModel: EmployeeHomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AsyncContentView(state: viewModel.state, retry: viewModel.load) { summary in
            List {
                headerSection

                Section("Statistika") {
                    LabeledContent {
                        Text("\(summary.studentsCount)")
                            .accessibilityIdentifier("total_students_count")
                    } label: {
                        Label {
                            Text("Ümumi tələbə sayı")
                            Text("+\(summary.newStudentsThisMonth) bu ay")
                        } icon: {
                            Image(systemName: "person.3.fill")
                        }
                    }

                    LabeledContent {
                        Text("\(summary.activeStudentsCount)")
                    } label: {
                        Label("Aktiv tələbə", systemImage: "chart.bar.fill")
                    }

                    NavigationLink(value: EmployeeRoute.teachers) {
                        LabeledContent {
                            Text("\(summary.teachersCount)")
                        } label: {
                            Label("Müəllimlər", systemImage: "person.2.fill")
                        }
                    }
                    .accessibilityIdentifier("teachers_tile")

                    LabeledContent {
                        Text("\(summary.groupsCount)")
                    } label: {
                        Label("Qruplar", systemImage: "square.grid.2x2.fill")
                    }

                    LabeledContent {
                        Text("\(summary.announcementsCount)")
                    } label: {
                        Label("Elanlar", systemImage: "megaphone.fill")
                    }
                }

                if !summary.recentAnnouncements.isEmpty {
                    Section("Son elanlar") {
                        ForEach(summary.recentAnnouncements) { announcement in
                            NavigationLink(value: announcement) {
                                AnnouncementRow(announcement: announcement)
                            }
                        }
                    }
                }
            }
            .font(.manropeRegular(16))
            .refreshable {
                await viewModel.load()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.greeting)
                        .font(.manropeBold(24))
                        .accessibilityIdentifier("employee_greeting")

                    Text("Bugünkü icmalı nəzərdən keçirin")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let user = authenticationState.currentUser {
                    AvatarView(firstName: user.firstName, lastName: user.lastName, size: 52)
                }
            }
            .listRowBackground(Color.clear)
        }
    }
}
