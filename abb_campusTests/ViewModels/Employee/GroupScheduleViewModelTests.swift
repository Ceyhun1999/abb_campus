import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("Employee: group schedule and schedule import")
struct GroupScheduleViewModelTests {

    private static let teacher = StudyGroup.TeacherReference(id: 21, firstName: "Kamal", lastName: "Əliyev")
    private static let today = DateFormatting.date(fromAPI: "2026-10-20") ?? Date()

    private func lesson(_ id: Int, _ date: String, _ startsAt: String) -> ScheduleLesson {
        ScheduleLesson(id: id, title: "Dərs \(id)", date: date, startsAt: startsAt, endsAt: "23:00", room: nil, description: nil)
    }

    private func makeSUT(_ service: MockGroupService, group: StudyGroup? = nil) -> GroupScheduleViewModel {
        GroupScheduleViewModel(
            group: group ?? .stub(teacher: Self.teacher),
            scheduleSource: service,
            lessonService: MockLessonService(),
            scheduleImporter: service,
            today: { Self.today }
        )
    }

    // MARK: - Load

    @Test("Upcoming lessons are grouped by day in order, starting today")
    func upcomingSections() async {
        let service = MockGroupService()
        service.scheduleResult = .success([
            lesson(1, "2026-10-22", "11:00"),
            lesson(2, "2026-10-20", "09:00"),
            lesson(3, "2026-10-22", "09:00"),
            lesson(4, "2026-10-19", "09:00")
        ])
        let sut = makeSUT(service)

        await sut.load()

        #expect(sut.sections.map(\.date) == ["2026-10-20", "2026-10-22"])
        #expect(sut.sections.first?.title == "Bu gün")
        #expect(sut.sections.last?.lessons.map(\.id) == [3, 1])
    }

    @Test("Past lessons are shown newest day first")
    func pastSections() async {
        let service = MockGroupService()
        service.scheduleResult = .success([lesson(1, "2026-10-01", "09:00"), lesson(2, "2026-10-19", "09:00"), lesson(3, "2026-10-21", "09:00")])
        let sut = makeSUT(service)

        await sut.load()
        sut.period = .past

        #expect(sut.sections.map(\.date) == ["2026-10-19", "2026-10-01"])
    }

    @Test("An empty schedule suggests importing one")
    func emptySchedule() async {
        let sut = makeSUT(MockGroupService())

        await sut.load()

        #expect(sut.sections.isEmpty)
        #expect(sut.emptyMessage == "Qrupun cədvəli hələ yoxdur. Excel faylından idxal edin.")
    }

    @Test("A failed load shows the error")
    func loadFailure() async {
        let service = MockGroupService()
        service.scheduleResult = .failure(NetworkError.serverUnreachable)
        let sut = makeSUT(service)

        await sut.load()

        #expect(sut.state.errorMessage == NetworkError.serverUnreachable.localizedDescription)
    }

    @Test("A failed refresh keeps the loaded schedule")
    func refreshFailureKeepsData() async {
        let service = MockGroupService()
        service.scheduleResult = .success([lesson(1, "2026-10-21", "09:00")])
        let sut = makeSUT(service)
        await sut.load()

        service.scheduleResult = .failure(NetworkError.noConnection)
        await sut.load()

        #expect(sut.state.value?.count == 1)
    }

    // MARK: - Import

    @Test("Import opens a schedule import for this group")
    func showImport() {
        let sut = makeSUT(MockGroupService(), group: .stub(id: 5, teacher: Self.teacher))

        sut.showImport()

        #expect(sut.isImportPresented)
        #expect(sut.importViewModel?.kind == .schedule)
        #expect(sut.importViewModel?.group.id == 5)
    }

    @Test("A group without a teacher cannot import a schedule")
    func importNeedsTeacher() {
        let sut = makeSUT(MockGroupService(), group: .stub(teacher: nil))

        sut.showImport()

        #expect(sut.importBlockedReason?.hasPrefix("Əvvəlcə qrupa müəllim təyin edin.") == true)
        #expect(sut.isImportPresented == false)
        #expect(sut.importViewModel == nil)
    }

    @Test("A finished group cannot import a schedule")
    func finishedGroupCannotImport() {
        let sut = makeSUT(MockGroupService(), group: .stub(teacher: Self.teacher, isActive: false))

        sut.showImport()

        #expect(sut.importBlockedReason == "Qrup bitib. Bitmiş qrupa cədvəl idxal etmək olmaz.")
        #expect(sut.isImportPresented == false)
    }

    @Test("The schedule reloads after the import screen closes")
    func reloadAfterImport() async {
        let service = MockGroupService()
        let sut = makeSUT(service)
        await sut.load()
        sut.showImport()

        service.scheduleResult = .success([lesson(1, "2026-10-21", "09:00")])
        await sut.importPresentationChanged(true)
        #expect(sut.state.value?.isEmpty == true)

        await sut.importPresentationChanged(false)
        #expect(sut.state.value?.count == 1)
        #expect(sut.importViewModel == nil)
    }

    @Test("A schedule import uploads the file to the schedule endpoint")
    func scheduleImportUsesScheduleService() async {
        let service = MockGroupService()
        service.importResult = .success(ImportResult(imported: 12, skipped: 0, errors: []))
        let sut = GroupImportViewModel(group: .stub(id: 4), kind: .schedule, groupService: service, fileLoader: MockFileLoader())
        sut.fileSelected(.success(URL(fileURLWithPath: "/tmp/cedvel.xlsx")))

        await sut.importFile()

        #expect(service.importedScheduleFiles.first?.groupId == 4)
        #expect(service.importedScheduleFiles.first?.fileName == "cedvel.xlsx")
        #expect(service.importedFiles.isEmpty)
        #expect(sut.result.value?.imported == 12)
        #expect(sut.kind.successMessage(imported: 12) == "12 dərs cədvələ əlavə olundu")
    }

    @Test("Group detail opens the schedule of the loaded group")
    func groupDetailOpensSchedule() async {
        let service = MockGroupService()
        service.groupResult = .success(.stub(id: 1, name: "IOS-02", teacher: Self.teacher))
        let sut = GroupDetailViewModel(group: .stub(), groupService: service, teacherService: MockTeacherService())
        await sut.load()

        sut.showSchedule()

        #expect(sut.isSchedulePresented)
        #expect(sut.scheduleGroup.name == "IOS-02")
        #expect(sut.scheduleGroup.teacher?.id == Self.teacher.id)
    }
}
