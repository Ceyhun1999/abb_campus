import Foundation
import Observation

// MARK: - Attendance

@MainActor
@Observable
final class GroupAttendanceViewModel {

    let page: MonthlyGroupPage<GroupAttendanceSummary>
    private let teachingService: any TeachingService

    init(
        group: StudyGroup,
        teachingService: any TeachingService,
        fileLoader: (any FileDataLoader)? = nil,
        today: Date = Date()
    ) {
        self.teachingService = teachingService
        self.page = MonthlyGroupPage(group: group, fileLoader: fileLoader, today: today) { month in
            try await teachingService.fetchAttendanceSummary(groupId: group.id, month: month)
        }
    }

    var report: MonthlyLoader<GroupAttendanceSummary> {
        page.report
    }

    var importFlow: ImportFlow {
        page.importFlow
    }

    /// "12 dərs günü" for the shown month.
    func lessonDaysText(_ summary: GroupAttendanceSummary) -> String {
        summary.dates.isEmpty ? "Bu ay üçün davamiyyət yüklənməyib" : "\(summary.dates.count) dərs günü"
    }

    func showImport() {
        let groupId = page.group.id
        let service = teachingService

        page.startImport(.attendance) { fileName, data in
            try await service.importAttendance(groupId: groupId, fileName: fileName, fileData: data)
        }
    }
}

// MARK: - Scores

@MainActor
@Observable
final class GroupScoresViewModel {

    let page: MonthlyGroupPage<[GroupAssessment]>
    private let teachingService: any TeachingService

    init(
        group: StudyGroup,
        teachingService: any TeachingService,
        fileLoader: (any FileDataLoader)? = nil,
        today: Date = Date()
    ) {
        self.teachingService = teachingService
        self.page = MonthlyGroupPage(group: group, fileLoader: fileLoader, today: today) { month in
            try await teachingService.fetchAssessments(groupId: group.id, month: month)
        }
    }

    var report: MonthlyLoader<[GroupAssessment]> {
        page.report
    }

    var importFlow: ImportFlow {
        page.importFlow
    }

    func tasks(_ assessments: [GroupAssessment]) -> [GroupAssessment] {
        assessments.filter { $0.kind == .task }
    }

    func exams(_ assessments: [GroupAssessment]) -> [GroupAssessment] {
        assessments.filter { $0.kind == .exam }
    }

    /// "Orta bal: 84.5 / 100"
    func averageText(_ assessment: GroupAssessment) -> String {
        guard let average = assessment.average else {
            return "Bal yoxdur"
        }

        return "Orta bal: \(ScoreFormatting.text(average)) / \(assessment.maxScore)"
    }

    /// Uploads the task scores of the month on screen.
    func showImport() {
        let groupId = page.group.id
        let month = report.month
        let service = teachingService

        page.startImport(.taskScores(month: month.title)) { fileName, data in
            try await service.importTaskScores(groupId: groupId, month: month.apiValue, fileName: fileName, fileData: data)
        }
    }
}
