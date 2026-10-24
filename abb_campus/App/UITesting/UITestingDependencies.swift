#if DEBUG
import Foundation

// MARK: - UI Testing

extension AppDependencies {

    static var uiTesting: AppDependencies {
        let directory = UITestingDirectory()
        let teaching = UITestingTeaching()

        return AppDependencies(
            authService: UITestingAuthService(),
            passwordResetService: UITestingPasswordResetService(),
            dashboardService: directory,
            studentDirectoryService: directory,
            teacherService: directory,
            groupService: directory,
            announcementService: directory,
            studentService: UITestingStudentService(),
            teachingService: teaching,
            lessonService: teaching,
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
    static let teacherEmail = "teacher@abb.local"
    static let teacherToken = "ui-testing-teacher-token"
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

    private let teacher = User(
        id: 21,
        firstName: "Kamal",
        lastName: "Əliyev",
        email: UITestingCredentials.teacherEmail,
        role: .teacher
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
        case (UITestingCredentials.teacherEmail, .teacher): (teacher, UITestingCredentials.teacherToken)
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
        case UITestingCredentials.teacherToken: return teacher
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

    private var groupSchedule: [ScheduleLesson] = []

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

    func fetchStudents(search: String, courseId: Int?, page: Int) async throws -> Page<DirectoryStudent> {
        let items = students.filter { student in
            let studentCourseId = groups.first { $0.id == student.group?.id }?.course?.id
            let matchesCourse = courseId == nil || studentCourseId == courseId
            let matchesSearch = search.isEmpty
                || student.fullName.localizedCaseInsensitiveContains(search)
                || (student.group?.name.localizedCaseInsensitiveContains(search) ?? false)

            return matchesSearch && matchesCourse
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
        teachers = teachers.map { $0.id == userId ? $0.withStatus(isActive) : $0 }
    }

    func deleteStudent(id: Int) async throws {
        students.removeAll { $0.id == id }
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

    func importStudents(groupId: Int, fileName: String, fileData: Data) async throws -> ImportResult {
        ImportResult(imported: 0, skipped: 1, errors: [
            .init(row: 4, email: "wrong-email", message: "E-poçt düzgün deyil.")
        ])
    }

    func fetchSchedule(groupId: Int) async throws -> [ScheduleLesson] {
        groupSchedule
    }

    func importSchedule(groupId: Int, fileName: String, fileData: Data) async throws -> ImportResult {
        let day = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        groupSchedule = [
            ScheduleLesson(id: 11, title: "Networking", date: DateFormatting.apiString(from: day),
                           startsAt: "09:00", endsAt: "10:30", room: "A-101", description: nil),
            ScheduleLesson(id: 12, title: "SwiftData", date: DateFormatting.apiString(from: day),
                           startsAt: "11:00", endsAt: "12:30", room: "A-101", description: nil)
        ]
        return ImportResult(imported: groupSchedule.count, skipped: 0, errors: [])
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

    func fetchAssessments() async throws -> [StudentAssessment] {
        [
            StudentAssessment(id: 4, kind: .exam, title: "SwiftUI modulu imtahanı", month: "2026-10",
                              examDate: "2026-10-17", score: 88, maxScore: 100),
            StudentAssessment(id: 1, kind: .task, title: "SwiftUI layout", month: "2026-10",
                              examDate: nil, score: 92, maxScore: 100),
            StudentAssessment(id: 2, kind: .task, title: "State və Binding", month: "2026-10",
                              examDate: nil, score: 85, maxScore: 100),
            StudentAssessment(id: 3, kind: .task, title: "Swift əsasları", month: "2026-09",
                              examDate: nil, score: 78, maxScore: 100)
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
    func requestCode(email: String, role: UserRole) async throws {}
    func verifyCode(email: String, role: UserRole, code: String) async throws {}
    func resetPassword(email: String, role: UserRole, code: String, password: String) async throws {}
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

    private(set) var appearanceMode: AppearanceMode = .system

    func setAppearanceMode(_ mode: AppearanceMode) {
        appearanceMode = mode
    }
}

// MARK: - Teacher Data

final class UITestingTeaching: TeachingService, LessonService {

    private static func day(_ offset: Int) -> String {
        DateFormatting.apiString(from: Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date())
    }

    private let group = StudyGroup(
        id: 1, name: "IOS-01", course: Course(id: 7, name: "Mobile Development iOS"),
        teacher: .init(id: 21, firstName: "Kamal", lastName: "Əliyev"), mentors: nil,
        startDate: "2026-07-01", endDate: "2027-07-01", isActive: true, studentsCount: 2, progress: 60
    )

    private var lessons: [ScheduleLesson] = [
        ScheduleLesson(id: 101, title: "SwiftUI layout", date: day(1), startsAt: "19:00", endsAt: "21:00",
                       room: "402", description: nil, groupName: "IOS-01"),
        ScheduleLesson(id: 102, title: "Networking", date: day(3), startsAt: "19:00", endsAt: "21:00",
                       room: "402", description: nil, groupName: "IOS-01"),
        ScheduleLesson(id: 103, title: "Modul 1 imtahanı", date: day(-2), startsAt: "10:00", endsAt: "12:00",
                       room: "B-2", description: nil, kind: .exam, groupName: "IOS-01")
    ]

    func fetchMyGroups() async throws -> [StudyGroup] {
        [group]
    }

    func fetchMySchedule() async throws -> [ScheduleLesson] {
        lessons
    }

    func fetchSchedule(groupId: Int) async throws -> [ScheduleLesson] {
        lessons
    }

    func fetchStudents(groupId: Int) async throws -> [GroupStudent] {
        [
            GroupStudent(id: 11, firstName: "Nihad", lastName: "Məmmədov", email: "nihad@abb.local"),
            GroupStudent(id: 12, firstName: "Leyla", lastName: "Həsənli", email: "leyla@abb.local")
        ]
    }

    func fetchAttendanceSummary(groupId: Int, month: String) async throws -> GroupAttendanceSummary {
        GroupAttendanceSummary(month: month, dates: [], students: [
            .init(studentId: 11, fullName: "Nihad Məmmədov", email: "nihad@abb.local",
                  present: 0, late: 0, absent: 0, excused: 0, total: 0, percentage: nil)
        ])
    }

    func fetchAssessments(groupId: Int, month: String) async throws -> [GroupAssessment] {
        []
    }

    func scheduleExam(groupId: Int, _ request: ExamFormRequest) async throws -> ScheduleLesson {
        let exam = ScheduleLesson(
            id: (lessons.map(\.id).max() ?? 100) + 1, title: request.title, date: request.date,
            startsAt: request.startsAt, endsAt: request.endsAt, room: request.room,
            description: nil, kind: .exam, groupName: "IOS-01"
        )
        lessons.append(exam)
        return exam
    }

    func importAttendance(groupId: Int, fileName: String, fileData: Data) async throws -> ImportResult {
        ImportResult(imported: 0, skipped: 0, errors: [])
    }

    func importTaskScores(groupId: Int, month: String, fileName: String, fileData: Data) async throws -> ImportResult {
        ImportResult(imported: 0, skipped: 0, errors: [])
    }

    func importExamScores(examId: Int, fileName: String, fileData: Data) async throws -> ImportResult {
        ImportResult(imported: 0, skipped: 0, errors: [])
    }

    func cancelLesson(id: Int, reason: CancelReason, note: String?) async throws -> ScheduleLesson {
        try update(id) { lesson in
            ScheduleLesson(id: lesson.id, title: lesson.title, date: lesson.date, startsAt: lesson.startsAt,
                           endsAt: lesson.endsAt, room: lesson.room, description: lesson.description,
                           kind: lesson.kind, isCancelled: true, cancelReason: reason, cancelNote: note,
                           groupName: lesson.groupName)
        }
    }

    func restoreLesson(id: Int) async throws -> ScheduleLesson {
        try update(id) { lesson in
            ScheduleLesson(id: lesson.id, title: lesson.title, date: lesson.date, startsAt: lesson.startsAt,
                           endsAt: lesson.endsAt, room: lesson.room, description: lesson.description,
                           kind: lesson.kind, groupName: lesson.groupName)
        }
    }

    private func update(_ id: Int, _ change: (ScheduleLesson) -> ScheduleLesson) throws -> ScheduleLesson {
        guard let index = lessons.firstIndex(where: { $0.id == id }) else {
            throw NetworkError.serverError(statusCode: 404, message: "Dərs tapılmadı.")
        }

        lessons[index] = change(lessons[index])
        return lessons[index]
    }
}

#endif
