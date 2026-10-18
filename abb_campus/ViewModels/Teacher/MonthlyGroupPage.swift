import Foundation
import Observation

/// What the monthly screens (attendance, scores) share: the group, the shown month's data,
/// and the Excel upload, after which the month reloads.
/// Months are limited to the group's dates: from its first month to its last (or the current one).
/// Finished groups still accept uploads: the last month often arrives after the course ends.
@MainActor
@Observable
final class MonthlyGroupPage<Value> {

    let group: StudyGroup
    let report: MonthlyLoader<Value>
    let importFlow = ImportFlow()

    @ObservationIgnored private let fileLoader: (any FileDataLoader)?

    init(
        group: StudyGroup,
        fileLoader: (any FileDataLoader)?,
        today: Date,
        fetch: @escaping (_ month: String) async throws -> Value
    ) {
        self.group = group
        self.fileLoader = fileLoader
        self.report = MonthlyLoader(
            today: today,
            from: group.startDate.flatMap(DateFormatting.date(fromAPI:)),
            until: group.endDate.flatMap(DateFormatting.date(fromAPI:)),
            fetch: fetch
        )

        let report = self.report
        importFlow.onFinish = {
            await report.load()
        }
    }

    func startImport(_ kind: ImportKind, upload: @escaping (_ fileName: String, _ data: Data) async throws -> ImportResult) {
        importFlow.start(GroupImportViewModel(group: group, kind: kind, fileLoader: fileLoader, upload: upload))
    }
}
