import SwiftUI

enum EmployeeRoute: Hashable {
    case announcements
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
                        groupService: dependencies.groupService,
                        teacherService: dependencies.teacherService
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
                case .announcements:
                    AnnouncementsListView(
                        viewModel: AnnouncementsListViewModel(
                            announcementService: dependencies.announcementService,
                            groupService: dependencies.groupService
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
