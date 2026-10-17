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

/// What a spreadsheet adds to a group.
enum ImportKind: Equatable {
    case students
    case schedule
    case attendance
    case taskScores(month: String)
    case examScores(exam: String)

    var navigationTitle: String {
        switch self {
        case .students: return "Tələbə importu"
        case .schedule: return "Cədvəl importu"
        case .attendance: return "Davamiyyət importu"
        case .taskScores: return "Tapşırıq balları"
        case .examScores: return "İmtahan balları"
        }
    }

    var columns: String {
        switch self {
        case .students: return "first_name, last_name, email"
        case .schedule: return "date, starts_at, ends_at, title, room, description"
        case .attendance: return "email və hər dərs tarixi üçün sütun (məsələn, 2026-10-06)"
        case .taskScores: return "email və hər tapşırıq üçün sütun"
        case .examScores: return "email, score"
        }
    }

    var hint: String? {
        switch self {
        case .students:
            return nil
        case .schedule:
            return "Yalnız faylın ilk və son tarixi arasındakı dərslər yenilənir, digər günlərin dərsləri qalır. Cədvəli ay-ay yükləyə bilərsiniz. İmtahanlar dəyişmir. Tarix: 2026-10-20, vaxt: 09:00."
        case .attendance:
            return "Xanalara + (var), - (yox), g (gecikib) və ya ü (üzrlü) yazın. Boş xana nəzərə alınmır. Eyni tarix yenidən yüklənsə, köhnə qeyd əvəz olunur."
        case .taskScores(let month):
            return "Ballar 0–100. Fayl \(month) ayının tapşırıq ballarını əvəz edəcək. Boş xana bal yoxdur deməkdir."
        case .examScores(let exam):
            return "«\(exam)» üçün ballar 0–100. Yenidən yükləmək köhnə balları əvəz edir."
        }
    }

    var submitTitle: String {
        switch self {
        case .students: return "Tələbələri idxal et"
        case .schedule: return "Cədvəli idxal et"
        case .attendance: return "Davamiyyəti idxal et"
        case .taskScores, .examScores: return "Balları idxal et"
        }
    }

    var progressMessage: String {
        switch self {
        case .students: return "Fayl yoxlanılır və tələbələr əlavə olunur. Bir neçə saniyə çəkə bilər."
        case .schedule: return "Fayl yoxlanılır və dərslər əlavə olunur. Bir neçə saniyə çəkə bilər."
        case .attendance, .taskScores, .examScores: return "Fayl yoxlanılır. Bir neçə saniyə çəkə bilər."
        }
    }

    func successMessage(_ result: ImportResult) -> String {
        let imported = result.imported

        switch self {
        case .students: return "\(imported) tələbə qrupa əlavə olundu"
        case .schedule: return Self.scheduleMessage(result)
        case .attendance: return "\(imported) davamiyyət qeydi yadda saxlandı"
        case .taskScores: return "\(imported) tapşırığın balları yükləndi"
        case .examScores: return "\(imported) tələbənin balı yükləndi"
        }
    }

    /// "12 dərs yükləndi: 05.10.2026 – 30.10.2026. Bu aralıqdan 2 köhnə dərs silindi."
    private static func scheduleMessage(_ result: ImportResult) -> String {
        var message = "\(result.imported) dərs yükləndi"

        if let from = DateFormatting.displayDate(from: result.from), let to = DateFormatting.displayDate(from: result.to) {
            message += from == to ? ": \(from)" : ": \(from) – \(to)"
        }

        if let removed = result.removed, removed > 0 {
            message += ". Bu aralıqdan \(removed) köhnə dərs silindi"
        }

        return message + "."
    }

    func rejectedMessage(errorCount: Int) -> String {
        let unchanged: String

        switch self {
        case .students: unchanged = "Heç bir tələbə əlavə olunmadı."
        case .schedule: unchanged = "Cədvəl dəyişmədi."
        case .attendance: unchanged = "Davamiyyət dəyişmədi."
        case .taskScores, .examScores: unchanged = "Ballar dəyişmədi."
        }

        return "\(errorCount) səhv var. \(unchanged) Excel-i düzəldib yenidən yükləyin."
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
    private let upload: (_ fileName: String, _ data: Data) async throws -> ImportResult
    private let fileLoader: any FileDataLoader

    /// - Parameter upload: sends the file to the server and returns the result.
    init(
        group: StudyGroup,
        kind: ImportKind,
        fileLoader: (any FileDataLoader)? = nil,
        upload: @escaping (_ fileName: String, _ data: Data) async throws -> ImportResult
    ) {
        self.group = group
        self.kind = kind
        self.fileLoader = fileLoader ?? SecurityScopedFileLoader()
        self.upload = upload
    }

    /// Student or schedule import of an employee.
    convenience init(
        group: StudyGroup,
        kind: ImportKind = .students,
        groupService: any GroupService,
        fileLoader: (any FileDataLoader)? = nil
    ) {
        let groupId = group.id

        self.init(group: group, kind: kind, fileLoader: fileLoader) { fileName, data in
            if kind == .schedule {
                return try await groupService.importSchedule(groupId: groupId, fileName: fileName, fileData: data)
            }

            return try await groupService.importStudents(groupId: groupId, fileName: fileName, fileData: data)
        }
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
            result = .loaded(try await upload(selectedFile.name, selectedFile.data))
        } catch {
            result = .idle
            errorMessage = error.localizedDescription
        }
    }
}
