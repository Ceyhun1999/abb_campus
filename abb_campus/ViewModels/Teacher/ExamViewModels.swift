import Foundation
import Observation

@MainActor
@Observable
final class GroupExamsViewModel {

    var isExamFormPresented = false
    private(set) var state: ViewState<[ScheduleLesson]> = .idle
    private(set) var examFormViewModel: ExamFormViewModel?
    let lessonActions: LessonActions
    let importFlow = ImportFlow()

    let group: StudyGroup
    private var latestRequest = LatestRequest()
    private let teachingService: any TeachingService
    private let fileLoader: (any FileDataLoader)?
    private let today: () -> Date

    init(
        group: StudyGroup,
        teachingService: any TeachingService,
        lessonService: any LessonService,
        fileLoader: (any FileDataLoader)? = nil,
        today: @escaping () -> Date = Date.init
    ) {
        self.group = group
        self.teachingService = teachingService
        self.fileLoader = fileLoader
        self.today = today
        self.lessonActions = LessonActions(lessonService: lessonService, today: today)

        lessonActions.onChange = { [weak self] lesson in
            self?.apply(lesson)
        }

        importFlow.onFinish = { [weak self] in
            await self?.load()
        }
    }

    // MARK: - Lists

    var upcomingExams: [ScheduleLesson] {
        exams.filter { $0.date >= todayString }
    }

    var pastExams: [ScheduleLesson] {
        exams.filter { $0.date < todayString }.reversed()
    }

    private var exams: [ScheduleLesson] {
        (state.value ?? [])
            .filter(\.isExam)
            .sorted { ($0.date, $0.startsAt) < ($1.date, $1.startsAt) }
    }

    private var todayString: String {
        DateFormatting.apiString(from: today())
    }

    func load() async {
        let request = latestRequest.start()

        if state.value == nil {
            state = .loading
        }

        do {
            let lessons = try await teachingService.fetchSchedule(groupId: group.id)

            if latestRequest.isCurrent(request) {
                state = .loaded(lessons)
            }
        } catch is CancellationError {
        } catch {
            if state.value == nil && latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }

    private func apply(_ lesson: ScheduleLesson) {
        if let lessons = state.value {
            state = .loaded(lessons.replacing(lesson))
        }
    }

    // MARK: - Schedule

    var canSchedule: Bool {
        group.isActive
    }

    func showExamForm() {
        guard canSchedule else {
            return
        }

        examFormViewModel = ExamFormViewModel(group: group, teachingService: teachingService, today: today)
        isExamFormPresented = true
    }

    func examScheduled(_ exam: ScheduleLesson) {
        isExamFormPresented = false
        examFormViewModel = nil
        state = .loaded((state.value ?? []) + [exam])
    }

    // MARK: - Scores

    /// Scores are uploaded on or after the exam day, for an exam that took place, even after the course ends.
    func canUploadScores(_ exam: ScheduleLesson) -> Bool {
        !exam.isCancelled && exam.date <= todayString
    }

    func showScoresImport(for exam: ScheduleLesson) {
        guard canUploadScores(exam) else {
            return
        }

        let service = teachingService
        let examId = exam.id

        importFlow.start(GroupImportViewModel(group: group, kind: .examScores(exam: exam.title), fileLoader: fileLoader) { fileName, data in
            try await service.importExamScores(examId: examId, fileName: fileName, fileData: data)
        })
    }
}

// MARK: - Exam Form

@MainActor
@Observable
final class ExamFormViewModel {

    static let maxTitleLength = 100
    static let maxRoomLength = 50

    var title = ""
    var date: Date
    var startTime: Date
    var endTime: Date
    var room = ""
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    let group: StudyGroup
    let dateRange: ClosedRange<Date>
    private let teachingService: any TeachingService

    init(group: StudyGroup, teachingService: any TeachingService, today: () -> Date = Date.init) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: today())
        let groupStart = group.startDate.flatMap(DateFormatting.date(fromAPI:)) ?? startOfToday
        let groupEnd = group.endDate.flatMap(DateFormatting.date(fromAPI:))
        let first = max(startOfToday, groupStart)
        let last = max(first, groupEnd ?? calendar.date(byAdding: .year, value: 1, to: first) ?? first)

        self.group = group
        self.teachingService = teachingService
        self.dateRange = first...last
        self.date = calendar.date(byAdding: .day, value: 7, to: first).map { min($0, last) } ?? first
        self.startTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: first) ?? first
        self.endTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: first) ?? first
    }

    var titleError: String? {
        let trimmed = trimmedTitle

        if trimmed.isEmpty {
            return nil
        }

        return trimmed.count > Self.maxTitleLength ? "Ad ən çoxu \(Self.maxTitleLength) simvol ola bilər." : nil
    }

    var timeError: String? {
        Self.time(endTime) > Self.time(startTime) ? nil : "Bitmə vaxtı başlama vaxtından sonra olmalıdır."
    }

    var canSave: Bool {
        !isSaving && !trimmedTitle.isEmpty && titleError == nil && timeError == nil
            && trimmedRoom.count <= Self.maxRoomLength
    }

    func dismissError() {
        errorMessage = nil
    }

    func save() async -> ScheduleLesson? {
        guard canSave else {
            return nil
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        let request = ExamFormRequest(
            title: trimmedTitle,
            date: DateFormatting.apiString(from: date),
            startsAt: Self.time(startTime),
            endsAt: Self.time(endTime),
            room: trimmedRoom.isEmpty ? nil : trimmedRoom
        )

        do {
            return try await teachingService.scheduleExam(groupId: group.id, request)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedRoom: String {
        room.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    /// "09:30", the format the API expects.
    static func time(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
}
