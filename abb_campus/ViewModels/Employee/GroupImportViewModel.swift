import Foundation
import Observation

protocol FileDataLoader {
    func loadData(from url: URL) throws -> Data
}

// MARK: - File Loader

struct SecurityScopedFileLoader: FileDataLoader {

    func loadData(from url: URL) throws -> Data {
        let didAccess = url.startAccessingSecurityScopedResource()

        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        return try Data(contentsOf: url)
    }
}

struct SelectedFile: Equatable {
    let name: String
    let data: Data

    var sizeDescription: String {
        ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
    }
}

// MARK: - Import Kind

/// What a spreadsheet adds to a group: its students or its lesson schedule.
enum ImportKind {
    case students
    case schedule

    var navigationTitle: String {
        switch self {
        case .students: return "Tələbə importu"
        case .schedule: return "Cədvəl importu"
        }
    }

    var columns: String {
        switch self {
        case .students: return "first_name, last_name, email"
        case .schedule: return "date, starts_at, ends_at, title, room, description"
        }
    }

    var hint: String? {
        switch self {
        case .students: return nil
        case .schedule: return "Fayl qrupun bütün cədvəlini əvəz edəcək. Tarix: 2026-10-20, vaxt: 09:00."
        }
    }

    var submitTitle: String {
        switch self {
        case .students: return "Tələbələri idxal et"
        case .schedule: return "Cədvəli idxal et"
        }
    }

    var progressMessage: String {
        switch self {
        case .students: return "Fayl yoxlanılır və tələbələr əlavə olunur. Bir neçə saniyə çəkə bilər."
        case .schedule: return "Fayl yoxlanılır və dərslər əlavə olunur. Bir neçə saniyə çəkə bilər."
        }
    }

    func successMessage(imported: Int) -> String {
        switch self {
        case .students: return "\(imported) tələbə qrupa əlavə olundu"
        case .schedule: return "\(imported) dərs cədvələ əlavə olundu"
        }
    }

    func rejectedMessage(errorCount: Int) -> String {
        switch self {
        case .students:
            return "\(errorCount) sətirdə səhv var. Heç bir tələbə əlavə olunmadı. Excel-i düzəldib yenidən yükləyin."
        case .schedule:
            return "\(errorCount) sətirdə səhv var. Cədvəl dəyişmədi. Excel-i düzəldib yenidən yükləyin."
        }
    }
}

// MARK: - View Model

@MainActor
@Observable
final class GroupImportViewModel {

    var isFilePickerPresented = false
    var isErrorListPresented = false
    private(set) var selectedFile: SelectedFile?
    private(set) var result: ViewState<ImportResult> = .idle
    private(set) var errorMessage: String?

    let group: StudyGroup
    let kind: ImportKind
    private let groupService: any GroupService
    private let fileLoader: any FileDataLoader

    init(
        group: StudyGroup,
        kind: ImportKind = .students,
        groupService: any GroupService,
        fileLoader: (any FileDataLoader)? = nil
    ) {
        self.group = group
        self.kind = kind
        self.groupService = groupService
        self.fileLoader = fileLoader ?? SecurityScopedFileLoader()
    }

    func dismissError() {
        errorMessage = nil
    }

    var canImport: Bool {
        selectedFile != nil && !result.isLoading
    }

    func showFilePicker() {
        isFilePickerPresented = true
    }

    static let maxFileSize = 5 * 1024 * 1024

    func fileSelected(_ selection: Result<URL, Error>) {
        result = .idle

        do {
            let url = try selection.get()
            let data = try fileLoader.loadData(from: url)

            guard data.count <= Self.maxFileSize else {
                selectedFile = nil
                errorMessage = ValidationMessage.fileTooLarge
                return
            }

            selectedFile = SelectedFile(name: url.lastPathComponent, data: data)
            errorMessage = nil
        } catch {
            selectedFile = nil
            errorMessage = ValidationMessage.fileNotReadable
        }
    }

    func removeFile() {
        selectedFile = nil
        result = .idle
        errorMessage = nil
    }

    func importFile() async {
        guard !result.isLoading else {
            return
        }

        guard let selectedFile else {
            errorMessage = ValidationMessage.fileNotSelected
            return
        }

        errorMessage = nil
        result = .loading

        do {
            result = .loaded(try await upload(selectedFile))
        } catch {
            result = .idle
            errorMessage = error.localizedDescription
        }
    }

    private func upload(_ file: SelectedFile) async throws -> ImportResult {
        switch kind {
        case .students:
            return try await groupService.importStudents(groupId: group.id, fileName: file.name, fileData: file.data)
        case .schedule:
            return try await groupService.importSchedule(groupId: group.id, fileName: file.name, fileData: file.data)
        }
    }
}
