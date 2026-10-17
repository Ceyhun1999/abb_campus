import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("Employee screens under concurrency")
struct EmployeeConcurrencyTests {

    private func authState() throws -> AuthenticationState {
        let state = AuthenticationState(secureStorage: MockSecureStorage(), authService: MockAuthService())
        try state.startSession(user: .stub(), token: "token")
        return state
    }

    // MARK: - Test A: an older response must not replace a newer one

    @Test("Home: an older dashboard response does not replace a newer one")
    func homeStaleResponse() async throws {
        let service = ControlledDashboardService()
        let sut = EmployeeHomeViewModel(authenticationState: try authState(), dashboardService: service)

        let first = Task { await sut.load() }
        await service.calls.waitForCalls(1)
        let second = Task { await sut.load() }
        await service.calls.waitForCalls(2)

        service.calls.resume(1, with: .success(.stub(studentsCount: 20)))
        await second.value
        service.calls.resume(0, with: .success(.stub(studentsCount: 10)))
        await first.value

        #expect(sut.state.value?.studentsCount == 20)
    }

    @Test("Group detail: an older response does not replace a newer one")
    func groupStaleResponse() async throws {
        let service = ControlledGroupService()
        let sut = GroupDetailViewModel(group: .stub(id: 1, name: "OLD"), groupService: service, teacherService: MockTeacherService())

        let first = Task { await sut.load() }
        await service.groupCalls.waitForCalls(1)
        let second = Task { await sut.load() }
        await service.groupCalls.waitForCalls(2)

        service.groupCalls.resume(1, with: .success(.stub(id: 1, name: "NEW")))
        await second.value
        service.groupCalls.resume(0, with: .success(.stub(id: 1, name: "OLD")))
        await first.value

        #expect(sut.state.value?.group.name == "NEW")
    }

    // MARK: - Test H: a slow load must not undo a status change

    @Test("Teacher: a slow load that finishes after deactivation does not bring back 'Aktiv'")
    func teacherStatusNotOverwritten() async {
        let service = ControlledTeacherService()
        let sut = TeacherDetailViewModel(teacher: .stub(id: 21), teacherService: service)

        let load = Task { await sut.load() }
        await service.teacherCalls.waitForCalls(1)

        await sut.toggleStatus()
        #expect(sut.state.value?.isActive == false)

        service.teacherCalls.resume(0, with: .success(.stub(id: 21, isActive: true)))
        await load.value

        #expect(sut.state.value?.isActive == false)
    }

    @Test("Student: a slow load that finishes after deactivation does not bring back 'Aktiv'")
    func studentStatusNotOverwritten() async {
        let service = ControlledStudentDirectoryService()
        let sut = StudentDetailViewModel(student: .stub(id: 11, isActive: true), studentService: service)

        let load = Task { await sut.load() }
        await service.studentCalls.waitForCalls(1)

        let toggle = Task { await sut.toggleStatus() }
        await service.studentCalls.waitForCalls(2)
        service.studentCalls.resume(1, with: .success(.stub(id: 11, isActive: false)))
        await toggle.value
        #expect(sut.state.value?.isActive == false)

        service.studentCalls.resume(0, with: .success(.stub(id: 11, isActive: true)))
        await load.value

        #expect(sut.state.value?.isActive == false)
    }

    // MARK: - Test E: cancellation is not an error

    @Test("Home: a cancelled refresh keeps the data on screen")
    func homeCancelledRefreshKeepsData() async {
        let service = ControlledDashboardService()
        let sut = EmployeeHomeViewModel(authenticationState: try! authState(), dashboardService: service)
        let first = Task { await sut.load() }
        await service.calls.waitForCalls(1)
        service.calls.resume(0, with: .success(.stub(studentsCount: 5)))
        await first.value

        let refresh = Task { await sut.load() }
        await service.calls.waitForCalls(2)
        service.calls.resume(1, with: .failure(CancellationError()))
        await refresh.value

        #expect(sut.state.value?.studentsCount == 5)
    }

    @Test("Group detail: a cancelled refresh keeps the data on screen")
    func groupCancelledRefreshKeepsData() async {
        let service = ControlledGroupService()
        let sut = GroupDetailViewModel(group: .stub(), groupService: service, teacherService: MockTeacherService())
        let first = Task { await sut.load() }
        await service.groupCalls.waitForCalls(1)
        service.groupCalls.resume(0, with: .success(.stub(name: "IOS-01")))
        await first.value

        let refresh = Task { await sut.load() }
        await service.groupCalls.waitForCalls(2)
        service.groupCalls.resume(1, with: .failure(CancellationError()))
        await refresh.value

        #expect(sut.state.value?.group.name == "IOS-01")
    }

    // MARK: - Test D: ten searches finishing in random order

    @Test("Lists: of ten overlapping searches only the last one is shown", arguments: [
        [9, 3, 0, 7, 1, 8, 2, 6, 4, 5],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        [5, 9, 8, 7, 6, 4, 3, 2, 1, 0]
    ])
    func tenOverlappingSearches(order: [Int]) async {
        struct Row: Identifiable, Equatable { let id: Int }
        let calls = PendingCalls<Page<Row>>()
        let sut = PagedList<Row>()

        var tasks: [Task<Void, Never>] = []
        for _ in 0..<10 {
            tasks.append(Task { _ = await sut.load { _ in try await calls.next() } })
            await calls.waitForCalls(tasks.count)
        }

        for index in order {
            calls.resume(index, with: .success(Page(items: [Row(id: index)], currentPage: 1, lastPage: 1)))
            await Task.yield()
        }

        for task in tasks {
            await task.value
        }

        #expect(sut.state.value == [Row(id: 9)])
        #expect(sut.isLoadingMore == false)
    }

    // MARK: - Test E: cancelled first page and next page

    @Test("Lists: a cancelled first load leaves no error and the next load works")
    func cancelledFirstLoad() async {
        struct Row: Identifiable, Equatable { let id: Int }
        let calls = PendingCalls<Page<Row>>()
        let sut = PagedList<Row>()

        let first = Task { _ = await sut.load { _ in try await calls.next() } }
        await calls.waitForCalls(1)
        calls.resume(0, with: .failure(CancellationError()))
        await first.value
        #expect(sut.state.errorMessage == nil)

        let second = Task { _ = await sut.load { _ in try await calls.next() } }
        await calls.waitForCalls(2)
        calls.resume(1, with: .success(Page(items: [Row(id: 1)], currentPage: 1, lastPage: 1)))
        await second.value

        #expect(sut.state.value == [Row(id: 1)])
    }

    @Test("Lists: a cancelled next page does not leave the spinner on")
    func cancelledNextPage() async throws {
        struct Row: Identifiable, Equatable { let id: Int }
        let calls = PendingCalls<Page<Row>>()
        let sut = PagedList<Row>()
        let first = Task { _ = await sut.load { _ in try await calls.next() } }
        await calls.waitForCalls(1)
        calls.resume(0, with: .success(Page(items: [Row(id: 1)], currentPage: 1, lastPage: 2)))
        await first.value

        let more = Task { await sut.loadMore(after: Row(id: 1)) }
        await calls.waitForCalls(2)
        #expect(sut.isLoadingMore)
        calls.resume(1, with: .failure(CancellationError()))
        await more.value

        #expect(sut.isLoadingMore == false)
        #expect(sut.hasMore)
    }
}
