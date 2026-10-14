import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("Employee home & students list")
struct EmployeeListViewModelTests {

    // MARK: - Home

    @Test("Dashboard loads statistics")
    func dashboardSuccess() async throws {
        let service = MockDashboardService()
        service.result = .success(.stub(studentsCount: 482))
        let state = try makeSignedInState()
        let sut = EmployeeHomeViewModel(authenticationState: state, dashboardService: service)

        await sut.load()

        #expect(sut.state.value?.studentsCount == 482)
        #expect(sut.greeting == "Salam, Ceyhun!")
    }

    @Test("Dashboard error is shown")
    func dashboardFailure() async throws {
        let service = MockDashboardService()
        service.result = .failure(NetworkError.noConnection)
        let sut = EmployeeHomeViewModel(authenticationState: try makeSignedInState(), dashboardService: service)

        await sut.load()

        #expect(sut.state.errorMessage == "İnternet bağlantısı yoxdur.")
    }

    @Test("Dashboard starts idle and loads once")
    func dashboardStartsIdle() async throws {
        let service = MockDashboardService()
        let sut = EmployeeHomeViewModel(authenticationState: try makeSignedInState(), dashboardService: service)

        #expect(sut.state == .idle)
        await sut.load()
        #expect(service.callCount == 1)
        #expect(sut.state.value != nil)
    }

    // MARK: - Students

    @Test("Search text is trimmed and the status filter is sent")
    func studentsQuery() async {
        let service = MockStudentDirectoryService()
        let sut = StudentsListViewModel(studentService: service)
        sut.searchText = "  Nihad "
        sut.statusFilter = .inactive

        await sut.load()

        #expect(service.lastSearch == "Nihad")
        #expect(service.lastStatus == .inactive)
        #expect(sut.state.value?.count == 1)
    }

    @Test("Empty search result produces an empty list with a helpful message")
    func studentsEmpty() async {
        let service = MockStudentDirectoryService()
        service.studentsResult = .success([])
        let sut = StudentsListViewModel(studentService: service)
        sut.searchText = "xyz"

        await sut.load()

        #expect(sut.state.value?.isEmpty == true)
        #expect(sut.emptyMessage.contains("xyz"))
    }

    @Test("Students error is shown")
    func studentsFailure() async {
        let service = MockStudentDirectoryService()
        service.studentsResult = .failure(NetworkError.serverError(statusCode: 500, message: "Server xətası."))
        let sut = StudentsListViewModel(studentService: service)

        await sut.load()

        #expect(sut.state.errorMessage == "Server xətası.")
    }

    @Test("Query changes when search or filter changes")
    func queryKey() {
        let sut = StudentsListViewModel(studentService: MockStudentDirectoryService())
        let initial = sut.query

        sut.statusFilter = .active
        #expect(sut.query != initial)

        let afterFilter = sut.query
        sut.searchText = "Leyla"
        #expect(sut.query != afterFilter)
    }

    // MARK: - Student detail

    @Test("Deactivating a student sends the inverted status and refreshes")
    func toggleStatusSuccess() async {
        let service = MockStudentDirectoryService()
        service.studentResult = .success(.stub(isActive: false))
        let sut = StudentDetailViewModel(student: .stub(isActive: true), studentService: service)

        #expect(sut.statusActionTitle == "Deaktiv et")
        await sut.toggleStatus()

        #expect(service.statusChanges.first?.isActive == false)
        #expect(sut.state.value?.isActive == false)
        #expect(sut.statusActionTitle == "Aktiv et")
        #expect(sut.isUpdatingStatus == false)
    }

    @Test("Status change error keeps the current student")
    func toggleStatusFailure() async {
        let service = MockStudentDirectoryService()
        service.setStatusError = NetworkError.serverError(statusCode: 403, message: "İcazə yoxdur.")
        let sut = StudentDetailViewModel(student: .stub(isActive: true), studentService: service)

        await sut.toggleStatus()

        #expect(sut.actionErrorMessage == "İcazə yoxdur.")
        #expect(sut.state.value?.isActive == true)
    }

    // MARK: - Groups

    @Test("Group detail loads the group and its students")
    func groupDetail() async {
        let service = MockGroupService()
        service.studentsResult = .success([GroupStudent(id: 1, firstName: "Ali", lastName: "Rzayev", email: "ali@abb.local")])
        let sut = GroupDetailViewModel(group: .stub(), groupService: service, teacherService: MockTeacherService())

        await sut.load()

        #expect(sut.state.value?.students.count == 1)
        #expect(sut.state.value?.group.name == "IOS-01")
    }

    @Test("Group detail fails when students cannot be loaded")
    func groupDetailFailure() async {
        let service = MockGroupService()
        service.studentsResult = .failure(NetworkError.unauthorized)
        let sut = GroupDetailViewModel(group: .stub(), groupService: service, teacherService: MockTeacherService())

        await sut.load()

        #expect(sut.state.errorMessage != nil)
    }

    private func makeSignedInState() throws -> AuthenticationState {
        let state = AuthenticationState(
            secureStorage: MockSecureStorage(),
            authService: MockAuthService()
        )
        try state.startSession(user: .stub(role: .employee), token: "token")
        return state
    }

    // MARK: - Teachers

    @Test("Teacher filters are sent to the service")
    func teacherFilters() async {
        let teacherService = MockTeacherService()
        let sut = TeachersListViewModel(teacherService: teacherService, groupService: MockGroupService())
        sut.positionFilter = .mentor
        sut.specialtyFilter = "UI/UX Design"

        await sut.load()

        #expect(teacherService.teacherQueries.last?.position == .mentor)
        #expect(teacherService.teacherQueries.last?.specialty == "UI/UX Design")
    }

    @Test("Specialties come from the course list")
    func teacherSpecialties() async {
        let sut = TeachersListViewModel(teacherService: MockTeacherService(), groupService: MockGroupService())

        await sut.loadSpecialties()

        #expect(sut.specialties == ["Mobile Development iOS"])
    }

    @Test("Changing a filter changes the query")
    func teacherQueryChanges() {
        let sut = TeachersListViewModel(teacherService: MockTeacherService(), groupService: MockGroupService())
        let initial = sut.query

        sut.positionFilter = .teacher

        #expect(sut.query != initial)
    }

    @Test("Changing a filter shows loading until new data arrives")
    func filterChangeShowsLoading() async {
        let sut = TeachersListViewModel(teacherService: MockTeacherService(), groupService: MockGroupService())
        await sut.load()
        #expect(sut.state.value != nil)

        sut.positionFilter = .mentor

        #expect(sut.state.isLoading)

        await sut.load()

        #expect(sut.state.value != nil)
    }

    @Test("Typing in search keeps the current list")
    func searchKeepsList() async {
        let sut = TeachersListViewModel(teacherService: MockTeacherService(), groupService: MockGroupService())
        await sut.load()

        sut.searchText = "Kam"

        #expect(sut.state.value != nil)
    }

    @Test("Reloading a loaded list finishes without the refreshing flag")
    func refreshingFlagResets() async {
        let sut = TeachersListViewModel(teacherService: MockTeacherService(), groupService: MockGroupService())
        await sut.load()

        sut.searchText = "Kam"
        await sut.queryChanged()

        #expect(sut.isRefreshing == false)
        #expect(sut.state.value != nil)
    }
}
