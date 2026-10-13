import SwiftUI

enum EmployeeRoute: Hashable {
    case teachers
}

// MARK: - Destinations

private struct EmployeeDestinations: ViewModifier {

    @Environment(\.dependencies) private var dependencies

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: DirectoryStudent.self) { student in
                StudentDetailView(
                    viewModel: StudentDetailViewModel(
                        student: student,
                        studentService: dependencies.studentDirectoryService
                    )
                )
            }
            .navigationDestination(for: StudyGroup.self) { group in
                GroupDetailView(
                    viewModel: GroupDetailViewModel(
                        group: group,
                        groupService: dependencies.groupService
                    )
                )
            }
            .navigationDestination(for: Teacher.self) { teacher in
                TeacherDetailView(
                    viewModel: TeacherDetailViewModel(
                        teacher: teacher,
                        teacherService: dependencies.teacherService
                    )
                )
            }
            .navigationDestination(for: Announcement.self) { announcement in
                AnnouncementDetailView(announcement: announcement)
            }
            .navigationDestination(for: EmployeeRoute.self) { route in
                switch route {
                case .teachers:
                    TeachersListView(
                        viewModel: TeachersListViewModel(
                            teacherService: dependencies.teacherService
                        )
                    )
                }
            }
    }
}

extension View {

    func employeeDestinations() -> some View {
        modifier(EmployeeDestinations())
    }
}
