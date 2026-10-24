import Foundation
import Observation

// MARK: - Cancel Lesson

@MainActor
@Observable
final class CancelLessonViewModel: Identifiable {

    static let maxNoteLength = 255

    var reason: CancelReason = .teacherSick
    var note = ""
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    let lesson: ScheduleLesson
    private let lessonService: any LessonService

    init(lesson: ScheduleLesson, lessonService: any LessonService) {
        self.lesson = lesson
        self.lessonService = lessonService
    }

    nonisolated var id: Int {
        lesson.id
    }

    var title: String {
        lesson.isExam ? "İmtahanı ləğv et" : "Dərsi ləğv et"
    }

    /// "20.10.2026 · 19:00 – 21:00"
    var lessonSummary: String {
        let day = DateFormatting.displayDate(from: lesson.date) ?? lesson.date
        return "\(day) · \(lesson.timeRange)"
    }

    var isNoteRequired: Bool {
        reason == .other
    }

    var notePlaceholder: String {
        isNoteRequired ? "Səbəbi yazın" : "Əlavə qeyd (istəyə bağlı)"
    }

    var canSubmit: Bool {
        !isSaving && (!isNoteRequired || !trimmedNote.isEmpty) && trimmedNote.count <= Self.maxNoteLength
    }

    func dismissError() {
        errorMessage = nil
    }

    /// The cancelled lesson, or `nil` when the server refused.
    func submit() async -> ScheduleLesson? {
        guard canSubmit else {
            return nil
        }

        isSaving = true
        errorMessage = nil

        defer {
            isSaving = false
        }

        do {
            return try await lessonService.cancelLesson(
                id: lesson.id,
                reason: reason,
                note: trimmedNote.isEmpty ? nil : trimmedNote
            )
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private var trimmedNote: String {
        note.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Lesson Actions

/// Cancelling for any list of lessons. The owner applies the changed lesson in `onChange`.
@MainActor
@Observable
final class LessonActions {

    var cancelViewModel: CancelLessonViewModel?
    private(set) var errorMessage: String?

    @ObservationIgnored var onChange: ((ScheduleLesson) -> Void)?

    private let lessonService: any LessonService
    private let today: () -> Date

    init(lessonService: any LessonService, today: @escaping () -> Date = Date.init) {
        self.lessonService = lessonService
        self.today = today
    }

    /// Lessons from today on can be cancelled; past lessons stay as they were.
    func canCancel(_ lesson: ScheduleLesson) -> Bool {
        !lesson.isCancelled && isTodayOrLater(lesson)
    }

    func startCancel(_ lesson: ScheduleLesson) {
        guard canCancel(lesson) else {
            return
        }

        cancelViewModel = CancelLessonViewModel(lesson: lesson, lessonService: lessonService)
    }

    func cancelFinished(_ lesson: ScheduleLesson) {
        cancelViewModel = nil
        onChange?(lesson)
    }

    func dismissError() {
        errorMessage = nil
    }

    private func isTodayOrLater(_ lesson: ScheduleLesson) -> Bool {
        lesson.date >= DateFormatting.apiString(from: today())
    }
}
