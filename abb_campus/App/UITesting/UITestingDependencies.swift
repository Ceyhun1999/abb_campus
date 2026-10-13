#if DEBUG
import Foundation

// Stub services used when the app is launched by UI tests (`-ui-testing`),
// so UI tests never depend on the real backend.

extension AppDependencies {

    static var uiTesting: AppDependencies {
        let directory = UITestingDirectory()

        return AppDependencies(
            authService: UITestingAuthService(),
            passwordResetService: UITestingPasswordResetService(),
            dashboardService: directory,
            studentDirectoryService: directory,
            teacherService: directory,
            groupService: directory,
            announcementService: directory,
            studentService: UITestingStudentService(),
            secureStorage: InMemorySecureStorage(),
            preferences: InMemoryPreferencesStore(),
            tokenStore: TokenStore()
        )
    }
}

enum UITestingCredentials {
    static let email = "student@abb.local"
    static let employeeEmail = "employee@abb.local"
    static let password = "Password123!"
    static let token = "ui-testing-token"
    static let employeeToken = "ui-testing-employee-token"
}

final class UITestingAuthService: AuthService {

    private let student = User(
        id: 1,
        firstName: "Ceyhun",
        lastName: "Rzayev",
        email: UITestingCredentials.email,
        role: .student
    )

    private let employee = User(
        id: 2,
        firstName: "Aysel",
        lastName: "Hüseynova",
        email: UITestingCredentials.employeeEmail,
        role: .employee
    )

    func login(
        email: String,
        password: String,
        role: UserRole
    ) async throws -> LoginResponse {
        try await Task.sleep(for: .milliseconds(300))

        let account: (User, String)? = switch (email, role) {
        case (UITestingCredentials.email, .student): (student, UITestingCredentials.token)
        case (UITestingCredentials.employeeEmail, .employee): (employee, UITestingCredentials.employeeToken)
        default: nil
        }

        guard let (user, token) = account,
              password == UITestingCredentials.password else {
            throw NetworkError.serverError(
                statusCode: 422,
                message: "Bu məlumatlarla hesab tapılmadı."
            )
        }

        return LoginResponse(
            success: true,
            data: LoginData(token: token, user: user)
        )
    }

    func me(token: String) async throws -> User {
        switch token {
        case UITestingCredentials.token: return student
        case UITestingCredentials.employeeToken: return employee
        default: throw NetworkError.unauthorized
        }
    }

    func logout(token: String) async throws {}
}

/// In-memory data for the employee screens.
final class UITestingDirectory: EmployeeDashboardService, StudentDirectoryService,
                                TeacherService, GroupService, AnnouncementService {

    private var students: [DirectoryStudent] = [
        DirectoryStudent(id: 11, firstName: "Nihad", lastName: "Məmmədov", email: "nihad@abb.local",
                         phone: "+994 50 123 45 67", isActive: true,
                         group: .init(id: 1, name: "IOS-01"), createdAt: "2026-09-12T10:00:00+00:00"),
        DirectoryStudent(id: 12, firstName: "Leyla", lastName: "Həsənli", email: "leyla@abb.local",
                         phone: nil, isActive: true,
                         group: .init(id: 2, name: "UIUX-01"), createdAt: "2026-09-14T10:00:00+00:00"),
        DirectoryStudent(id: 13, firstName: "Rəşad", lastName: "İsmayılov", email: "rashad@abb.local",
                         phone: nil, isActive: false,
                         group: .init(id: 1, name: "IOS-01"), createdAt: "2026-09-15T10:00:00+00:00")
    ]

    private let teachers = [
        Teacher(id: 21, firstName: "Kamal", lastName: "Əliyev", email: "kamal@abb.local",
                phone: "+994 50 987 65 43", specialty: "iOS Development", isActive: true,
                groupsCount: 1, groups: nil)
    ]

    private var groups = [
        StudyGroup(id: 1, name: "IOS-01", course: Course(id: 1, name: "iOS Development"),
                   teacher: .init(id: 21, firstName: "Kamal", lastName: "Əliyev"),
                   startDate: "2026-07-01", endDate: "2027-01-01", isActive: true,
                   studentsCount: 2, progress: 55),
        StudyGroup(id: 2, name: "UIUX-01", course: Course(id: 2, name: "UI/UX Design"),
                   teacher: nil, startDate: "2026-08-01", endDate: "2026-12-01", isActive: true,
                   studentsCount: 1, progress: 60)
    ]

    private var announcements = [
        Announcement(id: 1, title: "Bayram günü dərslər", message: "Dərs olmayacaq.",
                     target: .students, groupId: nil, groupName: nil, createdAt: "2026-10-10T09:00:00+00:00")
    ]

    func fetchDashboard() async throws -> DashboardSummary {
        DashboardSummary(
            studentsCount: students.count,
            activeStudentsCount: students.filter(\.isActive).count,
            newStudentsThisMonth: 2,
            teachersCount: teachers.count,
            groupsCount: groups.count,
            activeGroupsCount: groups.count,
            announcementsCount: announcements.count,
            recentAnnouncements: announcements
        )
    }

    func fetchStudents(search: String, status: StudentStatusFilter) async throws -> [DirectoryStudent] {
        students.filter { student in
            let matchesStatus = switch status {
            case .all: true
            case .active: student.isActive
            case .inactive: !student.isActive
            }
            let matchesSearch = search.isEmpty
                || student.fullName.localizedCaseInsensitiveContains(search)
                || (student.group?.name.localizedCaseInsensitiveContains(search) ?? false)

            return matchesStatus && matchesSearch
        }
    }

    func fetchStudent(id: Int) async throws -> DirectoryStudent {
        guard let student = students.first(where: { $0.id == id }) else {
            throw NetworkError.serverError(statusCode: 404, message: "Məlumat tapılmadı.")
        }

        return student
    }

    func setStatus(userId: Int, isActive: Bool) async throws {
        guard let index = students.firstIndex(where: { $0.id == userId }) else {
            return
        }

        let student = students[index]
        students[index] = DirectoryStudent(
            id: student.id, firstName: student.firstName, lastName: student.lastName,
            email: student.email, phone: student.phone, isActive: isActive,
            group: student.group, createdAt: student.createdAt
        )
    }

    func fetchTeachers(search: String) async throws -> [Teacher] {
        teachers
    }

    func fetchTeacher(id: Int) async throws -> Teacher {
        teachers[0]
    }

    func fetchGroups(search: String) async throws -> [StudyGroup] {
        search.isEmpty ? groups : groups.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    func fetchGroup(id: Int) async throws -> StudyGroup {
        groups.first { $0.id == id } ?? groups[0]
    }

    func fetchStudents(groupId: Int) async throws -> [GroupStudent] {
        students
            .filter { $0.group?.id == groupId }
            .map { GroupStudent(id: $0.id, firstName: $0.firstName, lastName: $0.lastName, email: $0.email) }
    }

    func fetchCourses() async throws -> [Course] {
        [Course(id: 1, name: "iOS Development"), Course(id: 2, name: "UI/UX Design")]
    }

    func createGroup(_ request: CreateGroupRequest) async throws -> StudyGroup {
        let group = StudyGroup(
            id: groups.count + 1, name: request.name, course: nil, teacher: nil,
            startDate: request.startDate, endDate: request.endDate, isActive: true,
            studentsCount: 0, progress: 0
        )
        groups.append(group)
        return group
    }

    func importStudents(groupId: Int, fileName: String, fileData: Data) async throws -> StudentImportResult {
        StudentImportResult(imported: 2, skipped: 1, errors: [
            .init(row: 4, email: "wrong-email", message: "E-poçt düzgün deyil.")
        ])
    }

    func fetchAnnouncements() async throws -> [Announcement] {
        announcements
    }

    func createAnnouncement(_ request: CreateAnnouncementRequest) async throws -> Announcement {
        let announcement = Announcement(
            id: announcements.count + 1, title: request.title, message: request.message,
            target: request.target, groupId: request.groupId, groupName: nil, createdAt: nil
        )
        announcements.insert(announcement, at: 0)
        return announcement
    }
}

final class UITestingStudentService: StudentService {

    func fetchGradesOverview() async throws -> GradesOverview {
        GradesOverview(
            modules: [
                ModuleScore(moduleId: 1, moduleName: "Swift əsasları", totalScore: 86, maxScore: 100),
                ModuleScore(moduleId: 2, moduleName: "SwiftUI və UI", totalScore: 78, maxScore: 100)
            ],
            averageScore: 82,
            overallScore: 82
        )
    }

    func fetchModuleGrades(moduleId: Int) async throws -> ModuleGrades {
        ModuleGrades(
            module: .init(id: moduleId, name: "Swift əsasları"),
            grades: [
                .init(category: "Homework", score: 28, maxScore: 35),
                .init(category: "Project", score: 36, maxScore: 40)
            ],
            totalScore: 64,
            maxScore: 75
        )
    }

    func fetchAttendance() async throws -> AttendanceSummary {
        AttendanceSummary(
            records: [
                AttendanceRecord(id: 1, date: "2026-10-09", status: .present, note: nil),
                AttendanceRecord(id: 2, date: "2026-10-07", status: .late, note: nil)
            ],
            totalDays: 2,
            presentDays: 2,
            attendancePercentage: 100
        )
    }

    func fetchSchedule() async throws -> [ScheduleLesson] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

        return [
            ScheduleLesson(id: 1, title: "SwiftUI layout", date: DateFormatting.apiString(from: tomorrow),
                           startsAt: "19:00", endsAt: "21:00", room: "402", description: nil)
        ]
    }

    func fetchAnnouncements() async throws -> [Announcement] {
        [
            Announcement(id: 1, title: "Bayram günü dərslər", message: "Dərs olmayacaq.",
                         target: .students, groupId: nil, groupName: nil, createdAt: "2026-10-10T09:00:00+00:00")
        ]
    }
}

final class UITestingPasswordResetService: PasswordResetService {
    func requestCode(email: String) async throws {}
    func verifyCode(email: String, code: String) async throws {}
    func resetPassword(email: String, code: String, password: String) async throws {}
}

final class InMemorySecureStorage: SecureStorage {

    private var storage: [String: Data] = [:]

    func save(_ data: Data, for account: String) throws {
        storage[account] = data
    }

    func read(for account: String) throws -> Data? {
        storage[account]
    }

    func delete(for account: String) throws {
        storage[account] = nil
    }
}

final class InMemoryPreferencesStore: PreferencesStore {

    private var emails: [UserRole: String] = [:]

    func lastLoginEmail(for role: UserRole) -> String? {
        emails[role]
    }

    func setLastLoginEmail(_ email: String?, for role: UserRole) {
        emails[role] = email
    }
}
#endif
