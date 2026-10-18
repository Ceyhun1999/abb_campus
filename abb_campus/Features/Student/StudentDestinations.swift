import SwiftUI

enum StudentRoute: Hashable {
    case attendance
}

private struct StudentDestinations: ViewModifier {

    @Environment(\.dependencies) private var dependencies

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Announcement.self) { announcement in
                AnnouncementDetailView(viewModel: AnnouncementDetailViewModel(announcement: announcement))
            }
            .navigationDestination(for: StudentRoute.self) { route in
                switch route {
                case .attendance:
                    AttendanceView(
                        viewModel: AttendanceViewModel(
                            studentService: dependencies.studentService
                        )
                    )
                }
            }
    }
}

extension View {

    func studentDestinations() -> some View {
        modifier(StudentDestinations())
    }
}
