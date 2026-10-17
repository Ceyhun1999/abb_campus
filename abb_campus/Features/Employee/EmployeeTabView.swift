import SwiftUI

struct EmployeeTabView: View {

    @Environment(AuthenticationState.self) private var authenticationState
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        TabView {
            NavigationStack {
                EmployeeHomeView(
                    viewModel: EmployeeHomeViewModel(
                        authenticationState: authenticationState,
                        dashboardService: dependencies.dashboardService
                    )
                )
                .employeeDestinations()
            }
            .tabItem {
                Label("Ana səhifə", systemImage: "house.fill")
            }

            NavigationStack {
                StudentsListView(
                    viewModel: StudentsListViewModel(
                        studentService: dependencies.studentDirectoryService,
                        groupService: dependencies.groupService
                    )
                )
                .employeeDestinations()
            }
            .tabItem {
                Label("Tələbələr", systemImage: "person.2.fill")
            }

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

            NavigationStack {
                TeachersListView(
                    viewModel: TeachersListViewModel(
                        teacherService: dependencies.teacherService,
                        groupService: dependencies.groupService
                    )
                )
                .employeeDestinations()
            }
            .tabItem {
                Label("Müəllimlər", systemImage: "person.crop.rectangle.stack.fill")
            }

            ProfileView(
                viewModel: ProfileViewModel(
                    authenticationState: authenticationState
                )
            )
            .tabItem {
                Label("Profil", systemImage: "person.fill")
            }
        }
    }
}
