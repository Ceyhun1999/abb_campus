import Foundation
@testable import abb_campus

final class MockDashboardService: EmployeeDashboardService {

    var result: Result<DashboardSummary, Error> = .success(.stub())
    private(set) var callCount = 0

    func fetchDashboard() async throws -> DashboardSummary {
        callCount += 1
        return try result.get()
    }
}

final class MockStudentDirectoryService: StudentDirectoryService {

    var studentsResult: Result<[DirectoryStudent], Error> = .success([.stub()])
    var studentResult: Result<DirectoryStudent, Error> = .success(.stub())
    var setStatusError: Error?

    private(set) var lastSearch: String?
    private(set) var lastStatus: StudentStatusFilter?
    private(set) var lastCourseId: Int?
    private(set) var statusChanges: [(userId: Int, isActive: Bool)] = []

    func fetchStudents(search: String, status: StudentStatusFilter, courseId: Int?) async throws -> [DirectoryStudent] {
        lastCourseId = courseId
        lastSearch = search
        lastStatus = status
        return try studentsResult.get()
    }

    func fetchStudent(id: Int) async throws -> DirectoryStudent {
        try studentResult.get()
    }

    func setStatus(userId: Int, isActive: Bool) async throws {
        statusChanges.append((userId, isActive))

        if let setStatusError {
            throw setStatusError
        }
    }
}

final class MockTeacherService: TeacherService {

    var teachersResult: Result<[Teacher], Error> = .success([.stub()])

    private(set) var teacherQueries: [(position: TeacherPositionFilter, specialty: String?)] = []
    var fetchDelay: Duration?

    func fetchTeachers(search: String, position: TeacherPositionFilter, specialty: String?) async throws -> [Teacher] {
        teacherQueries.append((position, specialty))

        if let fetchDelay {
            try await Task.sleep(for: fetchDelay)
        }

        return try teachersResult.get()
    }

    func fetchTeacher(id: Int) async throws -> Teacher {
        try teachersResult.get()[0]
    }

    var setStatusError: Error?
    private(set) var statusChanges: [(userId: Int, isActive: Bool)] = []

    func setStatus(userId: Int, isActive: Bool) async throws {
        statusChanges.append((userId, isActive))

        if let setStatusError {
            throw setStatusError
        }
    }
}

final class MockGroupService: GroupService {

    var groupsResult: Result<[StudyGroup], Error> = .success([.stub()])
    var groupResult: Result<StudyGroup, Error> = .success(.stub())
    var studentsResult: Result<[GroupStudent], Error> = .success([])
    var coursesResult: Result<[Course], Error> = .success([Course(id: 7, name: "Mobile Development iOS")])
    var createResult: Result<StudyGroup, Error> = .success(.stub())
    var createDelay: Duration?
    var importResult: Result<StudentImportResult, Error> = .success(
        StudentImportResult(imported: 5, skipped: 0, errors: [])
    )

    private(set) var createdRequests: [GroupFormRequest] = []
    private(set) var updatedRequests: [(id: Int, request: GroupFormRequest)] = []
    private(set) var importedFiles: [(groupId: Int, fileName: String, data: Data)] = []

    private(set) var groupCourseIds: [Int?] = []

    func fetchGroups(search: String, courseId: Int?) async throws -> [StudyGroup] {
        groupCourseIds.append(courseId)
        return try groupsResult.get()
    }

    func fetchGroup(id: Int) async throws -> StudyGroup {
        try groupResult.get()
    }

    func fetchStudents(groupId: Int) async throws -> [GroupStudent] {
        try studentsResult.get()
    }

    func fetchCourses() async throws -> [Course] {
        try coursesResult.get()
    }

    func createGroup(_ request: GroupFormRequest) async throws -> StudyGroup {
        createdRequests.append(request)

        if let createDelay {
            try await Task.sleep(for: createDelay)
        }

        return try createResult.get()
    }

    func updateGroup(id: Int, _ request: GroupFormRequest) async throws -> StudyGroup {
        updatedRequests.append((id, request))
        return try createResult.get()
    }

    func importStudents(groupId: Int, fileName: String, fileData: Data) async throws -> StudentImportResult {
        importedFiles.append((groupId, fileName, fileData))
        return try importResult.get()
    }
}

final class MockAnnouncementService: AnnouncementService {

    var listResult: Result<[Announcement], Error> = .success([.stub()])
    var createResult: Result<Announcement, Error> = .success(.stub())
    private(set) var createdRequests: [CreateAnnouncementRequest] = []

    func fetchAnnouncements() async throws -> [Announcement] {
        try listResult.get()
    }

    func createAnnouncement(_ request: CreateAnnouncementRequest) async throws -> Announcement {
        createdRequests.append(request)
        return try createResult.get()
    }
}

struct MockFileLoader: FileDataLoader {

    var result: Result<Data, Error> = .success(Data("first_name,last_name,email".utf8))

    func loadData(from url: URL) throws -> Data {
        try result.get()
    }
}

// MARK: - Stubs

extension DashboardSummary {

    static func stub(studentsCount: Int = 61) -> DashboardSummary {
        DashboardSummary(
            studentsCount: studentsCount,
            activeStudentsCount: 55,
            newStudentsThisMonth: 4,
            teachersCount: 5,
            groupsCount: 7,
            activeGroupsCount: 6,
            announcementsCount: 6,
            recentAnnouncements: [.stub()]
        )
    }
}

extension DirectoryStudent {

    static func stub(id: Int = 11, isActive: Bool = true) -> DirectoryStudent {
        DirectoryStudent(
            id: id,
            firstName: "Nihad",
            lastName: "Məmmədov",
            email: "nihad@abb.local",
            phone: nil,
            isActive: isActive,
            group: .init(id: 1, name: "IOS-01"),
            createdAt: "2026-10-12T10:00:00+00:00"
        )
    }
}

extension Teacher {

    static func stub(
        id: Int = 21,
        specialty: String = "Mobile Development iOS",
        position: TeacherPosition = .teacher,
        isActive: Bool = true
    ) -> Teacher {
        Teacher(
            id: id,
            firstName: "Kamal",
            lastName: "Əliyev",
            email: "kamal@abb.local",
            phone: nil,
            specialty: specialty,
            position: position,
            isActive: isActive,
            groupsCount: 2,
            groups: nil
        )
    }
}

extension StudyGroup {

    static func stub(id: Int = 1, name: String = "IOS-01") -> StudyGroup {
        StudyGroup(
            id: id,
            name: name,
            course: Course(id: 7, name: "iOS Development"),
            teacher: nil,
            mentors: nil,
            startDate: "2026-07-01",
            endDate: "2027-01-01",
            isActive: true,
            studentsCount: 10,
            progress: 50
        )
    }
}

extension Announcement {

    static func stub(id: Int = 1) -> Announcement {
        Announcement(
            id: id,
            title: "Bayram günü dərslər",
            message: "Dərs olmayacaq.",
            target: .students,
            groupId: nil,
            groupName: nil,
            createdAt: "2026-10-12T09:00:00+00:00"
        )
    }
}
