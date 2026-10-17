import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("Employee forms: create group, import, announcement")
struct EmployeeFormViewModelTests {

    // MARK: - Create group

    @Test("Options load and no course is selected by default")
    func createGroupOptions() async {
        let sut = GroupFormViewModel(groupService: MockGroupService(), teacherService: MockTeacherService())

        await sut.loadOptions()

        #expect(sut.options.value?.courses.count == 1)
        #expect(sut.selectedCourseId == nil)
        #expect(sut.availableTeachers.isEmpty)
        #expect(sut.availableMentors.isEmpty)
    }

    @Test("End date has to be chosen for a new group")
    func endDateRequired() async {
        let service = MockGroupService()
        let sut = GroupFormViewModel(groupService: service, teacherService: MockTeacherService())
        await sut.loadOptions()
        sut.name = "IOS-09"
        sut.selectedCourseId = 7

        #expect(sut.endDate == nil)

        _ = await sut.save()

        #expect(sut.errorMessage == ValidationMessage.endDateNotSelected)
        #expect(service.createdRequests.isEmpty)
    }

    @Test("A new form has no changes until something is entered")
    func newFormChanges() async {
        let sut = GroupFormViewModel(groupService: MockGroupService(), teacherService: MockTeacherService())
        await sut.loadOptions()

        #expect(sut.hasChanges == false)

        sut.name = "IOS-10"

        #expect(sut.hasChanges)

        sut.name = ""

        #expect(sut.hasChanges == false)
    }

    @Test("Editing has no changes until a field differs from the group")
    func editFormChanges() async {
        let group = StudyGroup(
            id: 5, name: "IOS-05", course: Course(id: 7, name: "Mobile Development iOS"),
            teacher: nil, mentors: [], startDate: "2026-09-01", endDate: "2027-03-01",
            isActive: true, studentsCount: 0, progress: nil
        )
        let sut = GroupFormViewModel(group: group, groupService: MockGroupService(), teacherService: MockTeacherService())
        await sut.loadOptions()

        #expect(sut.hasChanges == false)

        sut.isActive = false

        #expect(sut.hasChanges)
    }

    @Test("Group name is cut to 20 characters")
    func nameLimit() {
        let sut = GroupFormViewModel(groupService: MockGroupService(), teacherService: MockTeacherService())

        sut.name = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        sut.enforceNameLimit()

        #expect(sut.name == "ABCDEFGHIJKLMNOPQRST")
        #expect(sut.nameCounter == "20/20")
    }

    @Test("A group without a course is rejected")
    func courseRequired() async {
        let service = MockGroupService()
        let sut = GroupFormViewModel(groupService: service, teacherService: MockTeacherService())
        await sut.loadOptions()
        sut.name = "IOS-07"

        _ = await sut.save()

        #expect(sut.errorMessage == ValidationMessage.courseNotSelected)
        #expect(service.createdRequests.isEmpty)
    }

    @Test("Loaded options are not reloaded when the form appears again")
    func createGroupOptionsLoadedOnce() async {
        let groupService = MockGroupService()
        let sut = GroupFormViewModel(groupService: groupService, teacherService: MockTeacherService())
        await sut.loadOptions()

        groupService.coursesResult = .failure(NetworkError.noConnection)
        await sut.loadOptions()

        #expect(sut.options.value?.courses.count == 1)
    }

    @Test("A cancelled request is not shown as an error")
    func createGroupOptionsCancelled() async {
        let groupService = MockGroupService()
        groupService.coursesResult = .failure(CancellationError())
        let sut = GroupFormViewModel(groupService: groupService, teacherService: MockTeacherService())

        await sut.loadOptions()

        #expect(sut.options == .idle)
    }

    @Test("Teachers and mentors of the selected course are offered separately")
    func staffFilteredByCourse() async {
        let teacherService = MockTeacherService()
        teacherService.teachersResult = .success([
            .stub(id: 1, specialty: "Mobile Development iOS", position: .mentor),
            .stub(id: 2, specialty: "Mobile Development iOS", position: .teacher),
            .stub(id: 3, specialty: "UI/UX Design", position: .teacher)
        ])
        let sut = GroupFormViewModel(groupService: MockGroupService(), teacherService: teacherService)
        await sut.loadOptions()

        sut.selectedCourseId = 7

        #expect(sut.availableTeachers.map(\.id) == [2])
        #expect(sut.availableMentors.map(\.id) == [1])
    }

    @Test("Editing prefills the form and sends an update with mentors")
    func editGroup() async throws {
        let teacherService = MockTeacherService()
        teacherService.teachersResult = .success([
            .stub(id: 21, specialty: "Mobile Development iOS", position: .teacher),
            .stub(id: 31, specialty: "Mobile Development iOS", position: .mentor),
            .stub(id: 32, specialty: "Mobile Development iOS", position: .mentor)
        ])
        let groupService = MockGroupService()
        let group = StudyGroup(
            id: 5, name: "IOS-05", course: Course(id: 7, name: "Mobile Development iOS"),
            teacher: .init(id: 21, firstName: "Kamal", lastName: "Əliyev"),
            mentors: [.init(id: 31, firstName: "Fidan", lastName: "Kərimova")],
            startDate: "2026-09-01", endDate: "2027-03-01", isActive: true, studentsCount: 0, progress: nil
        )
        let sut = GroupFormViewModel(group: group, groupService: groupService, teacherService: teacherService)
        await sut.loadOptions()

        #expect(sut.isEditing)
        #expect(sut.name == "IOS-05")
        #expect(sut.selectedTeacherId == 21)
        #expect(sut.endDate.map(DateFormatting.apiString(from:)) == "2027-03-01")

        sut.toggleMentor(.stub(id: 32))
        sut.isActive = false
        _ = await sut.save()

        let update = try #require(groupService.updatedRequests.first)
        #expect(update.id == 5)
        #expect(update.request.mentorIds == [31, 32])
        #expect(update.request.isActive == false)
        #expect(groupService.createdRequests.isEmpty)
    }

    @Test("Inactive teachers and mentors are not offered")
    func inactiveStaffHidden() async {
        let teacherService = MockTeacherService()
        teacherService.teachersResult = .success([
            .stub(id: 1, position: .teacher, isActive: false),
            .stub(id: 2, position: .teacher),
            .stub(id: 3, position: .mentor, isActive: false),
            .stub(id: 4, position: .mentor)
        ])
        let sut = GroupFormViewModel(groupService: MockGroupService(), teacherService: teacherService)
        await sut.loadOptions()

        sut.selectedCourseId = 7

        #expect(sut.availableTeachers.map(\.id) == [2])
        #expect(sut.availableMentors.map(\.id) == [4])
    }

    @Test("Editing drops inactive staff from the selection and names them")
    func editingDropsInactiveStaff() {
        let group = StudyGroup(
            id: 5, name: "IOS-05", course: Course(id: 7, name: "Mobile Development iOS"),
            teacher: .init(id: 21, firstName: "Kamal", lastName: "Əliyev", isActive: false),
            mentors: [
                .init(id: 31, firstName: "Fidan", lastName: "Kərimova", isActive: false),
                .init(id: 32, firstName: "Elvin", lastName: "Həsənov", isActive: true)
            ],
            startDate: "2026-09-01", endDate: "2027-03-01", isActive: true, studentsCount: 0, progress: nil
        )

        let sut = GroupFormViewModel(group: group, groupService: MockGroupService(), teacherService: MockTeacherService())

        #expect(sut.selectedTeacherId == nil)
        #expect(sut.removedInactiveStaff == ["Kamal Əliyev", "Fidan Kərimova"])
        #expect(group.inactiveStaff.count == 2)
    }

    @Test("At most two mentors can be selected")
    func mentorLimit() async {
        let teacherService = MockTeacherService()
        teacherService.teachersResult = .success([
            .stub(id: 31, position: .mentor),
            .stub(id: 32, position: .mentor),
            .stub(id: 33, position: .mentor)
        ])
        let sut = GroupFormViewModel(groupService: MockGroupService(), teacherService: teacherService)
        await sut.loadOptions()
        sut.selectedCourseId = 7

        for mentor in sut.availableMentors {
            sut.toggleMentor(mentor)
        }

        #expect(sut.availableMentors.filter(sut.isMentorSelected).count == 2)
        #expect(sut.canSelectMentor(.stub(id: 33, position: .mentor)) == false)

        sut.toggleMentor(.stub(id: 31, position: .mentor))

        #expect(sut.canSelectMentor(.stub(id: 33, position: .mentor)))
    }

    @Test("Changing the course clears a teacher from another course")
    func courseChangeClearsTeacher() async {
        let groupService = MockGroupService()
        groupService.coursesResult = .success([
            Course(id: 7, name: "Mobile Development iOS"),
            Course(id: 8, name: "UI/UX Design")
        ])
        let sut = GroupFormViewModel(groupService: groupService, teacherService: MockTeacherService())
        await sut.loadOptions()
        sut.selectedTeacherId = 21

        sut.selectedCourseId = 8

        #expect(sut.selectedTeacherId == nil)
    }

    @Test("Closing the error alert clears the message")
    func dismissGroupFormError() async {
        let sut = GroupFormViewModel(groupService: MockGroupService(), teacherService: MockTeacherService())
        await sut.loadOptions()
        _ = await sut.save()
        #expect(sut.errorMessage == ValidationMessage.emptyGroupName)

        sut.dismissError()

        #expect(sut.errorMessage == nil)
    }

    @Test("Group name is required")
    func createGroupEmptyName() async {
        let service = MockGroupService()
        let sut = GroupFormViewModel(groupService: service, teacherService: MockTeacherService())
        sut.selectedCourseId = 7
        sut.name = "   "

        let group = await sut.save()

        #expect(group == nil)
        #expect(sut.errorMessage == ValidationMessage.emptyGroupName)
        #expect(service.createdRequests.isEmpty)
    }

    @Test("End date before start date is rejected")
    func createGroupInvalidDates() async {
        let sut = GroupFormViewModel(groupService: MockGroupService(), teacherService: MockTeacherService())
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
        let sut = GroupFormViewModel(groupService: service, teacherService: MockTeacherService())
        sut.name = " ios-03 "
        sut.selectedCourseId = 7
        sut.selectedTeacherId = 21
        sut.startDate = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 1)))
        sut.endDate = try #require(Calendar.current.date(from: DateComponents(year: 2027, month: 5, day: 1)))

        let group = await sut.save()

        #expect(group != nil)
        #expect(service.createdRequests == [
            GroupFormRequest(name: "IOS-03", courseId: 7, teacherId: 21, mentorIds: [],
                             startDate: "2026-11-01", endDate: "2027-05-01", isActive: true)
        ])
    }

    @Test("A second tap while saving does not send the group twice")
    func doubleTapSavesOnce() async {
        let service = MockGroupService()
        service.createDelay = .milliseconds(100)
        let sut = GroupFormViewModel(groupService: service, teacherService: MockTeacherService())
        sut.name = "IOS-08"
        sut.selectedCourseId = 7
        sut.endDate = Calendar.current.date(byAdding: .month, value: 6, to: sut.startDate)

        async let first = sut.save()
        async let second = sut.save()
        let results = await [first, second]

        #expect(service.createdRequests.count == 1)
        #expect(results.compactMap { $0 }.count == 1)
    }

    @Test("Server error while creating a group is shown")
    func createGroupFailure() async {
        let service = MockGroupService()
        service.createResult = .failure(NetworkError.serverError(statusCode: 422, message: "Bu ad artıq istifadə olunur."))
        let sut = GroupFormViewModel(groupService: service, teacherService: MockTeacherService())
        sut.name = "IOS-01"
        sut.selectedCourseId = 7
        sut.endDate = Calendar.current.date(byAdding: .month, value: 6, to: sut.startDate)

        let group = await sut.save()

        #expect(group == nil)
        #expect(sut.errorMessage == "Bu ad artıq istifadə olunur.")
        #expect(sut.isSaving == false)
    }

    // MARK: - Student import

    @Test("Selected file is read and the import result is shown")
    func importSuccess() async {
        let service = MockGroupService()
        service.importResult = .success(ImportResult(imported: 48, skipped: 0, errors: []))
        let sut = GroupImportViewModel(group: .stub(id: 9), groupService: service, fileLoader: MockFileLoader())

        sut.fileSelected(.success(URL(fileURLWithPath: "/tmp/telebeler.xlsx")))
        #expect(sut.selectedFile?.name == "telebeler.xlsx")
        #expect(sut.canImport)

        await sut.importFile()

        #expect(service.importedFiles.first?.groupId == 9)
        #expect(sut.result.value?.imported == 48)
        #expect(sut.result.value?.isRejected == false)
    }

    @Test("A file with errors is rejected and lists the rows")
    func importRejected() async {
        let service = MockGroupService()
        service.importResult = .success(ImportResult(imported: 0, skipped: 2, errors: [
            .init(row: 3, email: "bad", message: "E-poçt düzgün deyil."),
            .init(row: 5, email: "elvin@abb.local", message: "Bu email faylda təkrarlanır (2-ci sətir).")
        ]))
        let sut = GroupImportViewModel(group: .stub(id: 9), groupService: service, fileLoader: MockFileLoader())
        sut.fileSelected(.success(URL(fileURLWithPath: "/tmp/telebeler.xlsx")))

        await sut.importFile()

        #expect(sut.result.value?.isRejected == true)
        #expect(sut.result.value?.imported == 0)
        #expect(sut.result.value?.errors.map(\.row) == [3, 5])
    }

    @Test("Unreadable file shows an error")
    func importUnreadableFile() {
        let loader = MockFileLoader(result: .failure(CocoaError(.fileReadNoPermission)))
        let sut = GroupImportViewModel(group: .stub(), groupService: MockGroupService(), fileLoader: loader)

        sut.fileSelected(.success(URL(fileURLWithPath: "/tmp/x.xlsx")))

        #expect(sut.selectedFile == nil)
        #expect(sut.errorMessage == ValidationMessage.fileNotReadable)
    }

    @Test("A file over 5 MB is not accepted")
    func importTooLargeFile() {
        let loader = MockFileLoader(result: .success(Data(count: GroupImportViewModel.maxFileSize + 1)))
        let sut = GroupImportViewModel(group: .stub(), groupService: MockGroupService(), fileLoader: loader)

        sut.fileSelected(.success(URL(fileURLWithPath: "/tmp/boyuk.xlsx")))

        #expect(sut.selectedFile == nil)
        #expect(sut.errorMessage == ValidationMessage.fileTooLarge)
        #expect(sut.canImport == false)
    }

    @Test("Import without a file is rejected")
    func importWithoutFile() async {
        let service = MockGroupService()
        let sut = GroupImportViewModel(group: .stub(), groupService: service, fileLoader: MockFileLoader())

        await sut.importFile()

        #expect(sut.errorMessage == ValidationMessage.fileNotSelected)
        #expect(service.importedFiles.isEmpty)
    }

    @Test("Server error during import is shown and the result stays empty")
    func importFailure() async {
        let service = MockGroupService()
        service.importResult = .failure(NetworkError.serverError(statusCode: 422, message: "Fayl formatı dəstəklənmir."))
        let sut = GroupImportViewModel(group: .stub(), groupService: service, fileLoader: MockFileLoader())
        sut.fileSelected(.success(URL(fileURLWithPath: "/tmp/a.pdf")))

        await sut.importFile()

        #expect(sut.errorMessage == "Fayl formatı dəstəklənmir.")
        #expect(sut.result.value == nil)
    }

    // MARK: - Announcement

    @Test(
        "Announcement validation",
        arguments: [
            ("", "Mətn", ValidationMessage.emptyAnnouncementTitle),
            ("Başlıq", "  ", ValidationMessage.emptyAnnouncementMessage)
        ]
    )
    func announcementValidation(title: String, message: String, expected: String) async {
        let service = MockAnnouncementService()
        let sut = AnnouncementFormViewModel(announcementService: service)
        sut.title = title
        sut.message = message

        let result = await sut.save()

        #expect(result == nil)
        #expect(sut.errorMessage == expected)
        #expect(service.createdRequests.isEmpty)
    }

    @Test("A new announcement goes to everyone with medium priority by default")
    func announcementDefaults() {
        let sut = AnnouncementFormViewModel(announcementService: MockAnnouncementService())

        #expect(sut.target == .everyone)
        #expect(sut.priority == .medium)
    }

    @Test("Message is limited to 500 characters")
    func announcementMessageLimit() {
        let sut = AnnouncementFormViewModel(announcementService: MockAnnouncementService())

        sut.message = String(repeating: "a", count: 600)
        sut.enforceMessageLimit()

        #expect(sut.message.count == 500)
        #expect(sut.messageCounter == "500/500")
    }

    @Test("Title, message, audience and priority are sent", arguments: AnnouncementTarget.allCases)
    func announcementSuccess(target: AnnouncementTarget) async {
        let service = MockAnnouncementService()
        let sut = AnnouncementFormViewModel(announcementService: service)
        sut.title = " Müəllimlər iclası "
        sut.message = "Cümə axşamı saat 18:00-da iclas keçiriləcək."
        sut.target = target
        sut.priority = .high

        let published = await sut.save()

        #expect(published != nil)
        #expect(service.createdRequests.last == AnnouncementFormRequest(
            title: "Müəllimlər iclası",
            message: "Cümə axşamı saat 18:00-da iclas keçiriləcək.",
            target: target,
            priority: .high
        ))
    }

    @Test("Links are trimmed, get https:// when missing, and empty ones or repeats are dropped")
    func linkNormalization() {
        let drafts = [
            LinkDraft(text: "  abbtech.az "),
            LinkDraft(text: ""),
            LinkDraft(text: "https://developer.apple.com/swiftui"),
            LinkDraft(text: "https://abbtech.az")
        ]

        #expect(AnnouncementFormViewModel.normalizedLinks(drafts) == [
            "https://abbtech.az",
            "https://developer.apple.com/swiftui"
        ])
    }

    @Test("Invalid links are rejected", arguments: ["abbtech", "javascript:alert(1)", "https://abb tech.az", "http://.az"])
    func invalidLink(text: String) async {
        let service = MockAnnouncementService()
        let sut = AnnouncementFormViewModel(announcementService: service)
        sut.title = "Başlıq"
        sut.message = "Mətn"
        sut.links = [LinkDraft(text: text)]

        let published = await sut.save()

        #expect(published == nil)
        #expect(sut.errorMessage == ValidationMessage.invalidLink)
        #expect(service.createdRequests.isEmpty)
    }

    @Test("At most three link fields can be added and each can be removed")
    func linkFields() throws {
        let sut = AnnouncementFormViewModel(announcementService: MockAnnouncementService())

        for _ in 0..<5 {
            sut.addLink()
        }

        #expect(sut.links.count == 3)
        #expect(sut.canAddLink == false)

        sut.removeLink(try #require(sut.links.first))

        #expect(sut.links.count == 2)
        #expect(sut.canAddLink)
    }

    @Test("Links are sent with the announcement")
    func linksAreSent() async {
        let service = MockAnnouncementService()
        let sut = AnnouncementFormViewModel(announcementService: service)
        sut.title = "Mənbələr"
        sut.message = "Faydalı linklər"
        sut.links = [LinkDraft(text: "swift.org"), LinkDraft(text: "https://abbtech.az")]

        _ = await sut.save()

        #expect(service.createdRequests.last?.links == ["https://swift.org", "https://abbtech.az"])
    }

    @Test("Editing fills the form from the announcement and sends an update")
    func editAnnouncement() async throws {
        let service = MockAnnouncementService()
        let original = Announcement(
            id: 9, title: "İclas", message: "18:00", links: ["https://abbtech.az"],
            target: .teachers, priority: .high, createdAt: nil
        )
        let sut = AnnouncementFormViewModel(announcement: original, announcementService: service)

        #expect(sut.isEditing)
        #expect(sut.saveTitle == "Yadda saxla")
        #expect(sut.title == "İclas")
        #expect(sut.target == .teachers)
        #expect(sut.priority == .high)
        #expect(sut.links.map(\.text) == ["https://abbtech.az"])

        sut.message = "19:00"
        sut.removeLink(try #require(sut.links.first))
        let saved = await sut.save()

        let update = try #require(service.updatedRequests.first)
        #expect(update.id == 9)
        #expect(update.request.message == "19:00")
        #expect(update.request.links.isEmpty)
        #expect(saved?.message == "19:00")
        #expect(service.createdRequests.isEmpty)
    }

    // MARK: - Announcement Detail

    @Test("Students and teachers can only read an announcement")
    func readOnlyDetail() {
        let sut = AnnouncementDetailViewModel(announcement: .stub())

        sut.showEdit()

        #expect(sut.canManage == false)
        #expect(sut.isEditPresented == false)
    }

    @Test("A saved edit replaces the announcement on the detail screen")
    func detailEdit() throws {
        let sut = AnnouncementDetailViewModel(announcement: .stub(), announcementService: MockAnnouncementService())

        sut.showEdit()
        #expect(sut.isEditPresented)
        #expect(sut.editViewModel?.isEditing == true)

        sut.saved(.stub(priority: .high))

        #expect(sut.announcement.priority == .high)
        #expect(sut.isEditPresented == false)
        #expect(sut.editViewModel == nil)
    }

    @Test("Deleting asks first, then removes the announcement")
    func detailDelete() async {
        let service = MockAnnouncementService()
        let sut = AnnouncementDetailViewModel(announcement: .stub(id: 5), announcementService: service)

        sut.requestDelete()
        #expect(sut.isDeleteConfirmationPresented)

        await sut.delete()

        #expect(service.deletedIDs == [5])
        #expect(sut.isDeleted)
    }

    @Test("A failed delete keeps the announcement and shows the error")
    func detailDeleteFailure() async {
        let service = MockAnnouncementService()
        service.deleteError = NetworkError.noConnection
        let sut = AnnouncementDetailViewModel(announcement: .stub(), announcementService: service)

        await sut.delete()

        #expect(sut.isDeleted == false)
        #expect(sut.errorMessage == "İnternet bağlantısı yoxdur.")
    }

    @Test("Announcement server error is shown")
    func announcementFailure() async {
        let service = MockAnnouncementService()
        service.createResult = .failure(NetworkError.noConnection)
        let sut = AnnouncementFormViewModel(announcementService: service)
        sut.title = "Başlıq"
        sut.message = "Mətn"

        let published = await sut.save()

        #expect(published == nil)
        #expect(sut.errorMessage == "İnternet bağlantısı yoxdur.")
        #expect(sut.isSending == false)
    }
}
