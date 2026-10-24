import Foundation
import Testing
@testable import abb_campus

@MainActor
@Suite("Teacher: home, schedule, cancel lessons, monthly uploads, exams")
struct TeacherViewModelTests {

    private static let today = DateFormatting.date(fromAPI: "2026-10-20") ?? Date()

    private func makeAuthState() throws -> AuthenticationState {
        let state = AuthenticationState(secureStorage: MockSecureStorage(), authService: MockAuthService())
        try state.startSession(user: User(id: 21, firstName: "Kamal", lastName: "Əliyev", email: "t@abb.local", role: .teacher), token: "t")
        return state
    }

    // MARK: - Month Cursor

    @Test("Month cursor steps over the year and never goes past the current month")
    func monthCursor() {
        var month = MonthCursor(today: DateFormatting.date(fromAPI: "2026-01-15") ?? Date())
        #expect(month.apiValue == "2026-01")
        #expect(month.title == "Yanvar 2026")
        #expect(month.canGoForward == false)

        month.goForward()
        #expect(month.apiValue == "2026-01")

        month.goBack()
        #expect(month.apiValue == "2025-12")
        #expect(month.canGoForward)
        #expect(MonthCursor.title(forAPI: "2026-10") == "Oktyabr 2026")
    }

    @Test("Month cursor stays within the group's months")
    func monthCursorGroupBounds() {
        let date = { DateFormatting.date(fromAPI: $0) ?? Date() }
        var month = MonthCursor(today: date("2026-10-20"), from: date("2026-09-15"), until: date("2027-03-01"))
        #expect(month.apiValue == "2026-10")
        #expect(month.canGoForward == false)

        month.goBack()
        #expect(month.apiValue == "2026-09")
        #expect(month.canGoBack == false)

        month.goBack()
        #expect(month.apiValue == "2026-09", "no months before the group starts")

        let finished = MonthCursor(today: date("2026-10-20"), from: date("2026-01-10"), until: date("2026-06-30"))
        #expect(finished.apiValue == "2026-06", "a finished group opens on its last month")
        #expect(finished.canGoForward == false)

        let notStarted = MonthCursor(today: date("2026-10-20"), from: date("2026-12-01"), until: date("2027-06-01"))
        #expect(notStarted.apiValue == "2026-10")
        #expect(notStarted.canGoBack == false)
        #expect(notStarted.canGoForward == false)
    }

    // MARK: - Cancel Lesson

    @Test("Another reason needs a note before the lesson can be cancelled")
    func otherReasonNeedsNote() {
        let sut = CancelLessonViewModel(lesson: .stub(), lessonService: MockLessonService())
        #expect(sut.canSubmit)

        sut.reason = .other
        #expect(sut.canSubmit == false)

        sut.note = "   "
        #expect(sut.canSubmit == false)

        sut.note = "Otaq təmirdədir"
        #expect(sut.canSubmit)
    }

    @Test("Cancelling sends the reason and the trimmed note")
    func cancelSendsReason() async {
        let service = MockLessonService()
        let sut = CancelLessonViewModel(lesson: .stub(id: 7), lessonService: service)
        sut.reason = .holiday
        sut.note = "  Novruz  "

        let cancelled = await sut.submit()

        #expect(cancelled?.isCancelled == true)
        #expect(service.cancelled.first?.id == 7)
        #expect(service.cancelled.first?.reason == .holiday)
        #expect(service.cancelled.first?.note == "Novruz")
    }

    @Test("A refused cancellation shows the server message")
    func cancelFailure() async {
        let service = MockLessonService()
        service.error = NetworkError.serverError(statusCode: 422, message: "Keçmiş dərsi ləğv etmək olmaz.")
        let sut = CancelLessonViewModel(lesson: .stub(), lessonService: service)

        let cancelled = await sut.submit()

        #expect(cancelled == nil)
        #expect(sut.errorMessage == "Keçmiş dərsi ləğv etmək olmaz.")
        #expect(sut.isSaving == false)
    }

    @Test("Only lessons from today on can be cancelled, and a cancelled lesson stays cancelled")
    func lessonActionRules() {
        let sut = LessonActions(lessonService: MockLessonService(), today: { Self.today })

        #expect(sut.canCancel(.stub(date: "2026-10-20")))
        #expect(sut.canCancel(.stub(date: "2026-10-19")) == false)
        #expect(sut.canCancel(.stub(date: "2026-10-25", isCancelled: true)) == false)

        sut.startCancel(.stub(date: "2026-10-01"))
        #expect(sut.cancelViewModel == nil)
    }

    @Test("A cancelled lesson replaces the old one in the schedule")
    func scheduleUpdatesAfterActions() async {
        let teaching = MockTeachingService()
        teaching.scheduleResult = .success([.stub(id: 1, date: "2026-10-21", groupName: "IOS-01"), .stub(id: 2, date: "2026-10-22")])
        let lessons = MockLessonService()
        let sut = TeacherScheduleViewModel(teachingService: teaching, lessonService: lessons, today: { Self.today })
        await sut.load()

        sut.lessonActions.startCancel(try! #require(sut.state.value?.first))
        let cancelled = await sut.lessonActions.cancelViewModel?.submit()
        sut.lessonActions.cancelFinished(try! #require(cancelled))

        #expect(sut.state.value?.first?.isCancelled == true)
        #expect(sut.state.value?.first?.groupName == "IOS-01")
        #expect(sut.lessonActions.cancelViewModel == nil)
        #expect(lessons.cancelled.map(\.id) == [1])
    }

    @Test("A teacher sees the group schedule without the employee import")
    func teacherScheduleHasNoImport() async {
        let sut = GroupScheduleViewModel(
            group: .stub(),
            scheduleSource: MockTeachingService(),
            lessonService: MockLessonService(),
            today: { Self.today }
        )
        await sut.load()

        sut.showImport()

        #expect(sut.canImport == false)
        #expect(sut.importFlow.isPresented == false)
        #expect(sut.emptyMessage == "Qrupun cədvəli hələ yoxdur.")
    }

    // MARK: - Home

    @Test("Home shows the next five lessons that are not cancelled")
    func homeNextLessons() async throws {
        let teaching = MockTeachingService()
        teaching.groupsResult = .success([.stub(id: 1), .stub(id: 2)])
        teaching.scheduleResult = .success([
            .stub(id: 1, date: "2026-10-19"),
            .stub(id: 2, date: "2026-10-22", startsAt: "11:00"),
            .stub(id: 3, date: "2026-10-22", startsAt: "09:00"),
            .stub(id: 4, date: "2026-10-21", isCancelled: true),
            .stub(id: 5, date: "2026-10-23", kind: .exam),
            .stub(id: 6, date: "2026-10-24"),
            .stub(id: 7, date: "2026-10-25"),
            .stub(id: 8, date: "2026-10-26")
        ])
        let sut = TeacherHomeViewModel(authenticationState: try makeAuthState(), teachingService: teaching, today: { Self.today })

        await sut.load()
        let overview = try #require(sut.state.value)

        #expect(sut.greeting == "Salam, Kamal!")
        #expect(sut.nextLessons(overview).map(\.id) == [3, 2, 5, 6, 7])
        #expect(sut.upcomingExamsCount(overview) == 1)
        #expect(sut.studentsCount(overview) == 20)
    }

    @Test("Home shows an error when it cannot load")
    func homeFailure() async throws {
        let teaching = MockTeachingService()
        teaching.groupsResult = .failure(NetworkError.unauthorized)
        let sut = TeacherHomeViewModel(authenticationState: try makeAuthState(), teachingService: teaching)

        await sut.load()

        #expect(sut.state.errorMessage != nil)
    }

    @Test("Groups list loads the teacher's groups")
    func groupsList() async {
        let teaching = MockTeachingService()
        teaching.groupsResult = .success([.stub(id: 3, name: "IOS-03")])
        let sut = TeacherGroupsViewModel(teachingService: teaching)

        await sut.load()

        #expect(sut.state.value?.map(\.name) == ["IOS-03"])
    }

    // MARK: - Attendance

    @Test("Attendance loads the current month and the month before")
    func attendanceMonths() async {
        let teaching = MockTeachingService()
        let sut = GroupAttendanceViewModel(group: .stub(), teachingService: teaching, today: Self.today)

        await sut.report.load()
        await sut.report.goBack()
        await sut.report.goForward()
        await sut.report.goForward()

        #expect(teaching.requestedMonths == ["2026-10", "2026-09", "2026-10"])
        #expect(sut.report.month.title == "Oktyabr 2026")
    }

    @Test("Attendance upload goes to the attendance import and reloads after")
    func attendanceImport() async {
        let teaching = MockTeachingService()
        let sut = GroupAttendanceViewModel(group: .stub(id: 4), teachingService: teaching, fileLoader: MockFileLoader(), today: Self.today)

        sut.showImport()
        let importer = try! #require(sut.importFlow.viewModel)
        importer.fileSelected(.success(URL(fileURLWithPath: "/tmp/oktyabr.xlsx")))
        await importer.importFile()
        await sut.importFlow.presentationChanged(false)

        #expect(importer.kind == .attendance)
        #expect(teaching.attendanceUploads.first?.groupId == 4)
        #expect(teaching.requestedMonths == ["2026-10"])
        #expect(sut.importFlow.viewModel == nil)
    }

    @Test("A finished group still gets its last month's attendance")
    func finishedGroupAttendance() {
        let sut = GroupAttendanceViewModel(group: .stub(isActive: false), teachingService: MockTeachingService())

        sut.showImport()

        #expect(sut.importFlow.isPresented)
    }

    // MARK: - Scores

    @Test("Task scores are uploaded for the shown month")
    func taskScoresImport() async {
        let teaching = MockTeachingService()
        let sut = GroupScoresViewModel(group: .stub(id: 4), teachingService: teaching, fileLoader: MockFileLoader(), today: Self.today)
        await sut.report.goBack()

        sut.showImport()
        let importer = try! #require(sut.importFlow.viewModel)
        importer.fileSelected(.success(URL(fileURLWithPath: "/tmp/ballar.xlsx")))
        await importer.importFile()

        #expect(importer.kind == .taskScores(month: "Sentyabr 2026"))
        #expect(teaching.taskUploads.first?.month == "2026-09")
    }

    @Test("Scores are split into tasks and exams with their average")
    func scoresSplit() {
        let sut = GroupScoresViewModel(group: .stub(), teachingService: MockTeachingService())
        let task = GroupAssessment(id: 1, kind: .task, title: "Layout", month: "2026-10", examId: nil, maxScore: 100, average: 84.5, scores: [])
        let exam = GroupAssessment(id: 2, kind: .exam, title: "Final", month: "2026-10", examId: 9, maxScore: 100, average: nil, scores: [])

        #expect(sut.tasks([task, exam]) == [task])
        #expect(sut.exams([task, exam]) == [exam])
        #expect(sut.averageText(task) == "Orta bal: 84.5 / 100")
        #expect(sut.averageText(exam) == "Bal yoxdur")
    }

    // MARK: - Exams

    @Test("Exams are split into upcoming and past; scores only after the exam")
    func examsLists() async {
        let teaching = MockTeachingService()
        teaching.scheduleResult = .success([
            .stub(id: 1, date: "2026-10-25", kind: .exam),
            .stub(id: 2, date: "2026-10-01", kind: .exam),
            .stub(id: 3, date: "2026-10-15", kind: .exam, isCancelled: true),
            .stub(id: 4, date: "2026-10-21")
        ])
        let sut = GroupExamsViewModel(group: .stub(), teachingService: teaching, lessonService: MockLessonService(), today: { Self.today })

        await sut.load()

        #expect(sut.upcomingExams.map(\.id) == [1])
        #expect(sut.pastExams.map(\.id) == [3, 2])
        #expect(sut.canUploadScores(.stub(id: 2, date: "2026-10-01", kind: .exam)))
        #expect(sut.canUploadScores(.stub(id: 1, date: "2026-10-25", kind: .exam)) == false)
        #expect(sut.canUploadScores(.stub(id: 3, date: "2026-10-15", kind: .exam, isCancelled: true)) == false)
    }

    @Test("Exam scores upload to that exam and the list reloads")
    func examScoresImport() async {
        let teaching = MockTeachingService()
        let sut = GroupExamsViewModel(
            group: .stub(), teachingService: teaching, lessonService: MockLessonService(),
            fileLoader: MockFileLoader(), today: { Self.today }
        )
        let exam = ScheduleLesson.stub(id: 2, date: "2026-10-01", kind: .exam)

        sut.showScoresImport(for: exam)
        let importer = try! #require(sut.importFlow.viewModel)
        importer.fileSelected(.success(URL(fileURLWithPath: "/tmp/final.csv")))
        await importer.importFile()

        #expect(importer.kind == .examScores(exam: "Lesson 2"))
        #expect(teaching.examUploads.first?.examId == 2)
    }

    @Test("A new exam is added to the list after it is scheduled")
    func examScheduled() async {
        let sut = GroupExamsViewModel(group: .stub(), teachingService: MockTeachingService(), lessonService: MockLessonService(), today: { Self.today })
        await sut.load()

        sut.showExamForm()
        #expect(sut.isExamFormPresented)

        sut.examScheduled(.stub(id: 5, date: "2026-10-28", kind: .exam))

        #expect(sut.upcomingExams.map(\.id) == [5])
        #expect(sut.isExamFormPresented == false)
        #expect(sut.examFormViewModel == nil)
    }

    // MARK: - Exam Form

    @Test("Exam form needs a title and an end time after the start")
    func examFormValidation() {
        let sut = ExamFormViewModel(group: .stub(), teachingService: MockTeachingService(), today: { Self.today })
        #expect(sut.canSave == false)

        sut.title = "Modul 1 imtahanı"
        #expect(sut.canSave)

        sut.endTime = sut.startTime
        #expect(sut.timeError == "Bitmə vaxtı başlama vaxtından sonra olmalıdır.")
        #expect(sut.canSave == false)

        sut.endTime = sut.startTime.addingTimeInterval(3600)
        sut.title = String(repeating: "a", count: 101)
        #expect(sut.titleError != nil)
        #expect(sut.canSave == false)
    }

    @Test("Exam form sends the date and times in the API format")
    func examFormSave() async throws {
        let teaching = MockTeachingService()
        let sut = ExamFormViewModel(group: .stub(id: 4), teachingService: teaching, today: { Self.today })
        let calendar = Calendar.current
        sut.title = "  Final  "
        sut.room = " B-2 "
        sut.date = try #require(DateFormatting.date(fromAPI: "2026-11-02"))
        sut.startTime = try #require(calendar.date(bySettingHour: 9, minute: 30, second: 0, of: sut.date))
        sut.endTime = try #require(calendar.date(bySettingHour: 11, minute: 0, second: 0, of: sut.date))

        let exam = await sut.save()

        #expect(exam?.isExam == true)
        #expect(teaching.scheduledExams == [ExamFormRequest(title: "Final", date: "2026-11-02", startsAt: "09:30", endsAt: "11:00", room: "B-2")])
    }

    @Test("Exam form shows the server's refusal")
    func examFormFailure() async {
        let teaching = MockTeachingService()
        teaching.examResult = .failure(NetworkError.serverError(statusCode: 422, message: "Bu vaxtda artıq «SwiftUI» var."))
        let sut = ExamFormViewModel(group: .stub(), teachingService: teaching, today: { Self.today })
        sut.title = "Final"

        let exam = await sut.save()

        #expect(exam == nil)
        #expect(sut.errorMessage == "Bu vaxtda artıq «SwiftUI» var.")
    }

    @Test("Exam dates start today and end with the group")
    func examFormDateRange() {
        let sut = ExamFormViewModel(group: .stub(), teachingService: MockTeachingService(), today: { Self.today })

        #expect(DateFormatting.apiString(from: sut.dateRange.lowerBound) == "2026-10-20")
        #expect(DateFormatting.apiString(from: sut.dateRange.upperBound) == "2027-01-01")
    }
}

// MARK: - Student

@MainActor
@Suite("Student: cancelled lessons and exams")
struct StudentTeacherToolsTests {

    @Test("Lesson decodes cancellation and exam fields, with defaults for old responses")
    func decodeLesson() throws {
        let full = """
        {"id":1,"title":"SwiftUI","date":"2026-10-21","startsAt":"19:00","endsAt":"21:00","room":null,"description":null,
         "kind":"exam","isCancelled":true,"cancelReason":"holiday","cancelReasonTitle":"Bayram","cancelNote":"Novruz",
         "groupName":"IOS-01","hasScores":true}
        """
        let lesson = try JSONDecoder().decode(ScheduleLesson.self, from: Data(full.utf8))

        #expect(lesson.isExam)
        #expect(lesson.isCancelled)
        #expect(lesson.cancellationText == "Bayram. Novruz")
        #expect(lesson.groupName == "IOS-01")
        #expect(lesson.hasScores)

        let old = #"{"id":2,"title":"Layout","date":"2026-10-21","startsAt":"19:00","endsAt":"21:00"}"#
        let plain = try JSONDecoder().decode(ScheduleLesson.self, from: Data(old.utf8))

        #expect(plain.kind == .lesson)
        #expect(plain.isCancelled == false)
        #expect(plain.cancellationText == nil)
    }

    @Test("Other reason shows only the teacher's note")
    func otherReasonText() {
        let lesson = ScheduleLesson.stub(isCancelled: true, cancelReason: .other, cancelNote: "Otaq təmirdədir")

        #expect(lesson.cancellationText == "Otaq təmirdədir")
    }
}
