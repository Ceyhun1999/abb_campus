import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("Employee forms: create group, import, announcement")
struct EmployeeFormViewModelTests {

    // MARK: - Create group

    @Test("Options load and the first course is preselected")
    func createGroupOptions() async {
        let sut = CreateGroupViewModel(groupService: MockGroupService(), teacherService: MockTeacherService())

        await sut.loadOptions()

        #expect(sut.options.value?.courses.count == 1)
        #expect(sut.selectedCourseId == 7)
    }

    @Test("Loaded options are not reloaded when the form appears again")
    func createGroupOptionsLoadedOnce() async {
        let groupService = MockGroupService()
        let sut = CreateGroupViewModel(groupService: groupService, teacherService: MockTeacherService())
        await sut.loadOptions()

        groupService.coursesResult = .failure(NetworkError.noConnection)
        await sut.loadOptions()

        #expect(sut.options.value?.courses.count == 1)
    }

    @Test("A cancelled request is not shown as an error")
    func createGroupOptionsCancelled() async {
        let groupService = MockGroupService()
        groupService.coursesResult = .failure(CancellationError())
        let sut = CreateGroupViewModel(groupService: groupService, teacherService: MockTeacherService())

        await sut.loadOptions()

        #expect(sut.options == .idle)
    }

    @Test("Only teachers of the selected course are offered, teachers before mentors")
    func teachersFilteredByCourse() async {
        let teacherService = MockTeacherService()
        teacherService.teachersResult = .success([
            .stub(id: 1, specialty: "Mobil Tərtibatçılıq iOS", position: .mentor),
            .stub(id: 2, specialty: "Mobil Tərtibatçılıq iOS", position: .teacher),
            .stub(id: 3, specialty: "UI/UX Dizayn", position: .teacher)
        ])
        let sut = CreateGroupViewModel(groupService: MockGroupService(), teacherService: teacherService)

        await sut.loadOptions()

        #expect(sut.availableTeachers.map(\.id) == [2, 1])
    }

    @Test("Changing the course clears a teacher from another course")
    func courseChangeClearsTeacher() async {
        let groupService = MockGroupService()
        groupService.coursesResult = .success([
            Course(id: 7, name: "Mobil Tərtibatçılıq iOS"),
            Course(id: 8, name: "UI/UX Dizayn")
        ])
        let sut = CreateGroupViewModel(groupService: groupService, teacherService: MockTeacherService())
        await sut.loadOptions()
        sut.selectedTeacherId = 21

        sut.selectedCourseId = 8

        #expect(sut.selectedTeacherId == nil)
    }

    @Test("Group name is required")
    func createGroupEmptyName() async {
        let service = MockGroupService()
        let sut = CreateGroupViewModel(groupService: service, teacherService: MockTeacherService())
        sut.selectedCourseId = 7
        sut.name = "   "

        let group = await sut.save()

        #expect(group == nil)
        #expect(sut.errorMessage == ValidationMessage.emptyGroupName)
        #expect(service.createdRequests.isEmpty)
    }

    @Test("End date before start date is rejected")
    func createGroupInvalidDates() async {
        let sut = CreateGroupViewModel(groupService: MockGroupService(), teacherService: MockTeacherService())
        sut.name = "IOS-03"
        sut.selectedCourseId = 7
        sut.startDate = Date()
        sut.endDate = Date().addingTimeInterval(-86_400 * 3)

        _ = await sut.save()

        #expect(sut.errorMessage == ValidationMessage.invalidEndDate)
    }

    @Test("Valid form sends an uppercase name and API dates")
    func createGroupSuccess() async throws {
        let service = MockGroupService()
        let sut = CreateGroupViewModel(groupService: service, teacherService: MockTeacherService())
        sut.name = " ios-03 "
        sut.selectedCourseId = 7
        sut.selectedTeacherId = 21
        sut.startDate = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 1)))
        sut.hasEndDate = false

        let group = await sut.save()

        #expect(group != nil)
        #expect(service.createdRequests == [
            CreateGroupRequest(name: "IOS-03", courseId: 7, teacherId: 21, startDate: "2026-11-01", endDate: nil)
        ])
    }

    @Test("Server error while creating a group is shown")
    func createGroupFailure() async {
        let service = MockGroupService()
        service.createResult = .failure(NetworkError.serverError(statusCode: 422, message: "Bu ad artıq istifadə olunur."))
        let sut = CreateGroupViewModel(groupService: service, teacherService: MockTeacherService())
        sut.name = "IOS-01"
        sut.selectedCourseId = 7

        let group = await sut.save()

        #expect(group == nil)
        #expect(sut.errorMessage == "Bu ad artıq istifadə olunur.")
        #expect(sut.isSaving == false)
    }

    // MARK: - Student import

    @Test("Selected file is read and the import result is shown")
    func importSuccess() async {
        let service = MockGroupService()
        service.importResult = .success(StudentImportResult(imported: 48, skipped: 3, errors: [
            .init(row: 5, email: "bad", message: "E-poçt düzgün deyil.")
        ]))
        let sut = StudentImportViewModel(group: .stub(id: 9), groupService: service, fileLoader: MockFileLoader())

        sut.fileSelected(.success(URL(fileURLWithPath: "/tmp/telebeler.xlsx")))
        #expect(sut.selectedFile?.name == "telebeler.xlsx")
        #expect(sut.canImport)

        await sut.importStudents()

        #expect(service.importedFiles.first?.groupId == 9)
        #expect(sut.result.value?.imported == 48)
        #expect(sut.result.value?.totalRows == 51)
    }

    @Test("Unreadable file shows an error")
    func importUnreadableFile() {
        let loader = MockFileLoader(result: .failure(CocoaError(.fileReadNoPermission)))
        let sut = StudentImportViewModel(group: .stub(), groupService: MockGroupService(), fileLoader: loader)

        sut.fileSelected(.success(URL(fileURLWithPath: "/tmp/x.xlsx")))

        #expect(sut.selectedFile == nil)
        #expect(sut.errorMessage == ValidationMessage.fileNotReadable)
    }

    @Test("Import without a file is rejected")
    func importWithoutFile() async {
        let service = MockGroupService()
        let sut = StudentImportViewModel(group: .stub(), groupService: service, fileLoader: MockFileLoader())

        await sut.importStudents()

        #expect(sut.errorMessage == ValidationMessage.fileNotSelected)
        #expect(service.importedFiles.isEmpty)
    }

    @Test("Server error during import is shown and the result stays empty")
    func importFailure() async {
        let service = MockGroupService()
        service.importResult = .failure(NetworkError.serverError(statusCode: 422, message: "Fayl formatı dəstəklənmir."))
        let sut = StudentImportViewModel(group: .stub(), groupService: service, fileLoader: MockFileLoader())
        sut.fileSelected(.success(URL(fileURLWithPath: "/tmp/a.pdf")))

        await sut.importStudents()

        #expect(sut.errorMessage == "Fayl formatı dəstəklənmir.")
        #expect(sut.result.value == nil)
    }

    // MARK: - Announcement

    @Test(
        "Announcement validation",
        arguments: [
            ("", "Mətn", AnnouncementTarget.students, ValidationMessage.emptyAnnouncementTitle),
            ("Başlıq", "  ", AnnouncementTarget.students, ValidationMessage.emptyAnnouncementMessage),
            ("Başlıq", "Mətn", AnnouncementTarget.group, ValidationMessage.groupNotSelected)
        ]
    )
    func announcementValidation(title: String, message: String, target: AnnouncementTarget, expected: String) async {
        let service = MockAnnouncementService()
        let sut = NewAnnouncementViewModel(announcementService: service, groupService: MockGroupService())
        sut.title = title
        sut.message = message
        sut.target = target

        let result = await sut.publish()

        #expect(result == nil)
        #expect(sut.errorMessage == expected)
        #expect(service.createdRequests.isEmpty)
    }

    @Test("Message is limited to 500 characters")
    func announcementMessageLimit() {
        let sut = NewAnnouncementViewModel(announcementService: MockAnnouncementService(), groupService: MockGroupService())

        sut.message = String(repeating: "a", count: 600)

        #expect(sut.message.count == 500)
        #expect(sut.messageCounter == "500/500")
    }

    @Test("Group announcement sends the group id, others do not")
    func announcementSuccess() async {
        let service = MockAnnouncementService()
        let sut = NewAnnouncementViewModel(announcementService: service, groupService: MockGroupService())
        sut.title = " Dərs təxirə salındı "
        sut.message = "Cümə dərsi bazar ertəsinə keçirildi."
        sut.target = .group
        sut.selectedGroupId = 3

        let published = await sut.publish()

        #expect(published != nil)
        #expect(service.createdRequests.last == CreateAnnouncementRequest(
            title: "Dərs təxirə salındı",
            message: "Cümə dərsi bazar ertəsinə keçirildi.",
            target: .group,
            groupId: 3
        ))

        sut.target = .everyone
        _ = await sut.publish()
        #expect(service.createdRequests.last?.groupId == nil)
    }

    @Test("Announcement server error is shown")
    func announcementFailure() async {
        let service = MockAnnouncementService()
        service.createResult = .failure(NetworkError.noConnection)
        let sut = NewAnnouncementViewModel(announcementService: service, groupService: MockGroupService())
        sut.title = "Başlıq"
        sut.message = "Mətn"

        let published = await sut.publish()

        #expect(published == nil)
        #expect(sut.errorMessage == "İnternet bağlantısı yoxdur.")
        #expect(sut.isSending == false)
    }
}
