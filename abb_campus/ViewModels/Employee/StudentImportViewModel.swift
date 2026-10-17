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

@MainActor
@Observable
final class StudentImportViewModel {

    var isFilePickerPresented = false
    var isErrorListPresented = false
    private(set) var selectedFile: SelectedFile?
    private(set) var result: ViewState<StudentImportResult> = .idle
    private(set) var errorMessage: String?

    let group: StudyGroup
    private let groupService: any GroupService
    private let fileLoader: any FileDataLoader

    init(
        group: StudyGroup,
        groupService: any GroupService,
        fileLoader: any FileDataLoader = SecurityScopedFileLoader()
    ) {
        self.group = group
        self.groupService = groupService
        self.fileLoader = fileLoader
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

    func importStudents() async {
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
            result = .loaded(try await groupService.importStudents(
                groupId: group.id,
                fileName: selectedFile.name,
                fileData: selectedFile.data
            ))
        } catch {
            result = .idle
            errorMessage = error.localizedDescription
        }
    }
}
