import SwiftUI

enum EmployeeTab: Hashable {
    case home
    case students
    case groups
    case announcements
    case profile
}

struct EmployeeTabView: View {

    @Environment(AuthenticationState.self) private var authenticationState
    @Environment(\.dependencies) private var dependencies

    @State private var selectedTab: EmployeeTab = .home
    @State private var studentsFilterRequest: StudentStatusFilter?

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                EmployeeHomeView(
                    viewModel: EmployeeHomeViewModel(
                        authenticationState: authenticationState,
                        dashboardService: dependencies.dashboardService
                    ),
                    onOpenStudents: { filter in
                        studentsFilterRequest = filter
                        selectedTab = .students
                    },
                    onOpenTab: { tab in
                        selectedTab = tab
                    }
                )
                .employeeDestinations()
            }
            .tabItem {
                Label("Ana səhifə", systemImage: "house.fill")
            }
            .tag(EmployeeTab.home)

            NavigationStack {
                StudentsListView(
                    viewModel: StudentsListViewModel(
                        studentService: dependencies.studentDirectoryService
                    ),
                    filterRequest: $studentsFilterRequest
                )
                .employeeDestinations()
            }
            .tabItem {
                Label("Tələbələr", systemImage: "person.2.fill")
            }
            .tag(EmployeeTab.students)

            NavigationStack {
                GroupsListView(
                    viewModel: GroupsListViewModel(
                        groupService: dependencies.groupService,
                        teacherService: dependencies.teacherService
                    )
                )
                .employeeDestinations()
            }
            .tabItem {
                Label("Qruplar", systemImage: "square.grid.2x2.fill")
            }
            .tag(EmployeeTab.groups)

            NavigationStack {
                AnnouncementsListView(
                    viewModel: AnnouncementsListViewModel(
                        announcementService: dependencies.announcementService,
                        groupService: dependencies.groupService
                    )
                )
                .employeeDestinations()
            }
            .tabItem {
                Label("Elanlar", systemImage: "megaphone.fill")
            }
            .tag(EmployeeTab.announcements)

            ProfileView(
                viewModel: ProfileViewModel(
                    authenticationState: authenticationState
                )
            )
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
            .tag(EmployeeTab.profile)
        }
    }
}
