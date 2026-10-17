import Foundation
import Observation

// MARK: - Attendance

@MainActor
@Observable
final class GroupAttendanceViewModel {

    let report: MonthlyLoader<GroupAttendanceSummary>
    let importFlow = ImportFlow()

    let group: StudyGroup
    private let teachingService: any TeachingService
    private let fileLoader: (any FileDataLoader)?

    init(
        group: StudyGroup,
        teachingService: any TeachingService,
        fileLoader: (any FileDataLoader)? = nil,
        today: Date = Date()
    ) {
        self.group = group
        self.teachingService = teachingService
        self.fileLoader = fileLoader
        self.report = MonthlyLoader(today: today) { month in
            try await teachingService.fetchAttendanceSummary(groupId: group.id, month: month)
        }

        importFlow.onFinish = { [weak self] in
            await self?.report.load()
        }
    }

    var canImport: Bool {
        group.isActive
    }

    /// "12 dərs günü" for the shown month.
    func lessonDaysText(_ summary: GroupAttendanceSummary) -> String {
        summary.dates.isEmpty ? "Bu ay üçün davamiyyət yüklənməyib" : "\(summary.dates.count) dərs günü"
    }

    func showImport() {
        guard canImport else {
            return
        }

        let groupId = group.id
        let service = teachingService

        importFlow.start(GroupImportViewModel(group: group, kind: .attendance, fileLoader: fileLoader) { fileName, data in
            try await service.importAttendance(groupId: groupId, fileName: fileName, fileData: data)
        })
    }
}

// MARK: - Scores

@MainActor
@Observable
final class GroupScoresViewModel {

    let report: MonthlyLoader<[GroupAssessment]>
    let importFlow = ImportFlow()

    let group: StudyGroup
    private let teachingService: any TeachingService
    private let fileLoader: (any FileDataLoader)?

    init(
        group: StudyGroup,
        teachingService: any TeachingService,
        fileLoader: (any FileDataLoader)? = nil,
        today: Date = Date()
    ) {
        self.group = group
        self.teachingService = teachingService
        self.fileLoader = fileLoader
        self.report = MonthlyLoader(today: today) { month in
            try await teachingService.fetchAssessments(groupId: group.id, month: month)
        }

        importFlow.onFinish = { [weak self] in
            await self?.report.load()
        }
    }

    var canImport: Bool {
        group.isActive
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

    func showImport() {
        guard canImport else {
            return
        }

        let groupId = group.id
        let month = report.month.apiValue
        let service = teachingService

        importFlow.start(GroupImportViewModel(group: group, kind: .taskScores(month: report.month.title), fileLoader: fileLoader) { fileName, data in
            try await service.importTaskScores(groupId: groupId, month: month, fileName: fileName, fileData: data)
        })
    }
}

// MARK: - Score Formatting

enum ScoreFormatting {

    /// 90 → "90", 75.5 → "75.5"
    static func text(_ score: Double) -> String {
        score.rounded() == score ? String(Int(score)) : String(format: "%.1f", score)
    }
}
