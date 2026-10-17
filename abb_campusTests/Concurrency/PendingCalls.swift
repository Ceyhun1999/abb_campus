import Foundation
@testable import abb_campus

/// Holds every call until the test resumes it, so completion order is chosen by the test.
@MainActor
final class PendingCalls<Value: Sendable> {

    private var continuations: [CheckedContinuation<Value, Error>?] = []

    var count: Int {
        continuations.count
    }

    func next() async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func resume(_ index: Int, with result: Result<Value, Error>) {
        continuations[index]?.resume(with: result)
        continuations[index] = nil
    }

    func waitForCalls(_ expected: Int) async {
        while continuations.count < expected {
            await Task.yield()
        }
    }
}

// MARK: - Controlled services

@MainActor
final class ControlledDashboardService: EmployeeDashboardService {
    let calls = PendingCalls<DashboardSummary>()

    func fetchDashboard() async throws -> DashboardSummary {
        try await calls.next()
    }
}

@MainActor
final class ControlledTeacherService: TeacherService {
    let teacherCalls = PendingCalls<Teacher>()
    var statusChanges: [(userId: Int, isActive: Bool)] = []

    func fetchTeachers(search: String, position: TeacherPositionFilter, specialty: String?) async throws -> [Teacher] { [] }
    func fetchTeachersPage(search: String, position: TeacherPositionFilter, specialty: String?, page: Int) async throws -> Page<Teacher> {
        Page(items: [], currentPage: page, lastPage: 1)
    }

    func fetchTeacher(id: Int) async throws -> Teacher {
        try await teacherCalls.next()
    }

    func setStatus(userId: Int, isActive: Bool) async throws {
        statusChanges.append((userId, isActive))
    }
}

@MainActor
final class ControlledStudentDirectoryService: StudentDirectoryService {
    let studentCalls = PendingCalls<DirectoryStudent>()

    func fetchStudents(search: String, status: StudentStatusFilter, courseId: Int?, page: Int) async throws -> Page<DirectoryStudent> {
        Page(items: [], currentPage: page, lastPage: 1)
    }

    func fetchStudent(id: Int) async throws -> DirectoryStudent {
        try await studentCalls.next()
    }

    func setStatus(userId: Int, isActive: Bool) async throws {}
}

@MainActor
final class ControlledGroupService: GroupService {
    let groupCalls = PendingCalls<StudyGroup>()

    func fetchGroups(search: String, courseId: Int?) async throws -> [StudyGroup] { [] }
    func fetchGroupsPage(search: String, courseId: Int?, page: Int) async throws -> Page<StudyGroup> {
        Page(items: [], currentPage: page, lastPage: 1)
    }

    func fetchGroup(id: Int) async throws -> StudyGroup {
        try await groupCalls.next()
    }

    func fetchStudents(groupId: Int) async throws -> [GroupStudent] { [] }
    func fetchCourses() async throws -> [Course] { [] }
    func createGroup(_ request: GroupFormRequest) async throws -> StudyGroup { .stub() }
    func updateGroup(id: Int, _ request: GroupFormRequest) async throws -> StudyGroup { .stub() }
    func importStudents(groupId: Int, fileName: String, fileData: Data) async throws -> StudentImportResult {
        StudentImportResult(imported: 0, skipped: 0, errors: [])
    }
}
