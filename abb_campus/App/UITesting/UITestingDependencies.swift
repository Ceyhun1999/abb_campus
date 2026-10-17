#if DEBUG
import Foundation

// MARK: - UI Testing

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

    func changePassword(token: String, request: ChangePasswordRequest) async throws {
        guard request.currentPassword == UITestingCredentials.password else {
            throw NetworkError.serverError(statusCode: 422, message: "Cari şifrə yanlışdır.")
        }
    }

    func logout(token: String) async throws {}
}

// MARK: - Employee Data

final class UITestingDirectory: EmployeeDashboardService, StudentDirectoryService,
                                TeacherService, GroupService, AnnouncementService {

    private var students: [DirectoryStudent] = [
        DirectoryStudent(id: 11, firstName: "Nihad", lastName: "Məmmədov", email: "nihad@abb.local",
                         phone: "+994 50 123 45 67", isActive: true,
                         group: .init(id: 1, name: "IOS-01", courseName: "Mobile Development iOS"), createdAt: "2026-09-12T10:00:00+00:00"),
        DirectoryStudent(id: 12, firstName: "Leyla", lastName: "Həsənli", email: "leyla@abb.local",
                         phone: nil, isActive: true,
                         group: .init(id: 2, name: "UIUX-01", courseName: "UI/UX Design"), createdAt: "2026-09-14T10:00:00+00:00"),
        DirectoryStudent(id: 13, firstName: "Rəşad", lastName: "İsmayılov", email: "rashad@abb.local",
                         phone: nil, isActive: false,
                         group: .init(id: 1, name: "IOS-01", courseName: "Mobile Development iOS"), createdAt: "2026-09-15T10:00:00+00:00")
    ]

    private var teachers = [
        Teacher(id: 21, firstName: "Kamal", lastName: "Əliyev", email: "kamal@abb.local",
                phone: "+994 50 987 65 43", specialty: "Mobile Development iOS", position: .teacher, isActive: true,
                groupsCount: 1, groups: nil)
    ]

    private var groups = [
        StudyGroup(id: 1, name: "IOS-01", course: Course(id: 1, name: "Mobile Development iOS"),
                   teacher: .init(id: 21, firstName: "Kamal", lastName: "Əliyev"),
                   mentors: [.init(id: 22, firstName: "Fidan", lastName: "Kərimova")],
                   startDate: "2026-07-01", endDate: "2027-01-01", isActive: true,
                   studentsCount: 2, progress: 55),
        StudyGroup(id: 2, name: "UIUX-01", course: Course(id: 2, name: "UI/UX Design"),
                   teacher: nil, mentors: [], startDate: "2026-08-01", endDate: "2026-12-01", isActive: true,
                   studentsCount: 1, progress: 60)
    ]

    private var announcements = [
        Announcement(id: 1, title: "Bayram günü dərslər", message: "Dərs olmayacaq.",
                     target: .students, priority: .medium, createdAt: "2026-10-10T09:00:00+00:00")
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

    func fetchStudents(search: String, status: StudentStatusFilter, courseId: Int?, page: Int) async throws -> Page<DirectoryStudent> {
        let items = students.filter { student in
            let studentCourseId = groups.first { $0.id == student.group?.id }?.course?.id
            let matchesCourse = courseId == nil || studentCourseId == courseId
            let matchesStatus = switch status {
            case .all: true
            case .active: student.isActive
            case .inactive: !student.isActive
            }
            let matchesSearch = search.isEmpty
                || student.fullName.localizedCaseInsensitiveContains(search)
                || (student.group?.name.localizedCaseInsensitiveContains(search) ?? false)

            return matchesStatus && matchesSearch && matchesCourse
        }

        return Page(items: items, currentPage: page, lastPage: 1)
    }

    func fetchStudent(id: Int) async throws -> DirectoryStudent {
        guard let student = students.first(where: { $0.id == id }) else {
            throw NetworkError.serverError(statusCode: 404, message: "Məlumat tapılmadı.")
        }

        return student
    }

    func setStatus(userId: Int, isActive: Bool) async throws {
        guard let index = students.firstIndex(where: { $0.id == userId }) else {
            teachers = teachers.map { $0.id == userId ? $0.withStatus(isActive) : $0 }
            return
        }

        let student = students[index]
        students[index] = DirectoryStudent(
            id: student.id, firstName: student.firstName, lastName: student.lastName,
            email: student.email, phone: student.phone, isActive: isActive,
            group: student.group, createdAt: student.createdAt
        )
    }

    func fetchTeachers(search: String, position: TeacherPositionFilter, specialty: String?) async throws -> [Teacher] {
        teachers.filter { teacher in
            (position.queryValue == nil || (teacher.position ?? .teacher).rawValue == position.queryValue)
                && (specialty == nil || teacher.specialty == specialty)
        }
    }

    func fetchTeachersPage(search: String, position: TeacherPositionFilter, specialty: String?, page: Int) async throws -> Page<Teacher> {
        Page(items: try await fetchTeachers(search: search, position: position, specialty: specialty), currentPage: page, lastPage: 1)
    }

    func fetchTeacher(id: Int) async throws -> Teacher {
        teachers[0]
    }

    func fetchGroups(search: String, courseId: Int?) async throws -> [StudyGroup] {
        groups.filter { group in
            (search.isEmpty || group.name.localizedCaseInsensitiveContains(search))
                && (courseId == nil || group.course?.id == courseId)
        }
    }

    func fetchGroupsPage(search: String, courseId: Int?, page: Int) async throws -> Page<StudyGroup> {
        Page(items: try await fetchGroups(search: search, courseId: courseId), currentPage: page, lastPage: 1)
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
        [Course(id: 1, name: "Mobile Development iOS"), Course(id: 2, name: "UI/UX Design")]
    }

    func createGroup(_ request: GroupFormRequest) async throws -> StudyGroup {
        let group = makeGroup(id: groups.count + 1, request: request)
        groups.append(group)
        return group
    }

    func updateGroup(id: Int, _ request: GroupFormRequest) async throws -> StudyGroup {
        let group = makeGroup(id: id, request: request)
        groups = groups.map { $0.id == id ? group : $0 }
        return group
    }

    private func makeGroup(id: Int, request: GroupFormRequest) -> StudyGroup {
        StudyGroup(
            id: id, name: request.name, course: nil, teacher: nil, mentors: [],
            startDate: request.startDate, endDate: request.endDate, isActive: request.isActive,
            studentsCount: 0, progress: 0
        )
    }

    func importStudents(groupId: Int, fileName: String, fileData: Data) async throws -> StudentImportResult {
        StudentImportResult(imported: 0, skipped: 1, errors: [
            .init(row: 4, email: "wrong-email", message: "E-poçt düzgün deyil.")
        ])
    }

    func fetchAnnouncements(page: Int) async throws -> Page<Announcement> {
        Page(items: announcements, currentPage: page, lastPage: 1)
    }

    func createAnnouncement(_ request: AnnouncementFormRequest) async throws -> Announcement {
        let announcement = Announcement(
            id: (announcements.map(\.id).max() ?? 0) + 1, title: request.title, message: request.message,
            links: request.links, target: request.target, priority: request.priority, createdAt: nil
        )
        announcements.insert(announcement, at: 0)
        return announcement
    }

    func updateAnnouncement(id: Int, _ request: AnnouncementFormRequest) async throws -> Announcement {
        let announcement = Announcement(
            id: id, title: request.title, message: request.message,
            links: request.links, target: request.target, priority: request.priority, createdAt: nil
        )
        announcements = announcements.map { $0.id == id ? announcement : $0 }
        return announcement
    }

    func deleteAnnouncement(id: Int) async throws {
        announcements.removeAll { $0.id == id }
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
                         target: .students, priority: .medium, createdAt: "2026-10-10T09:00:00+00:00")
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
