import Foundation
import Observation

@MainActor
@Observable
final class StudentDetailViewModel {

    var isDeleteConfirmationPresented = false
    private(set) var state: ViewState<DirectoryStudent>
    private(set) var isDeleting = false
    /// Set once the student is deleted; the screen then closes.
    private(set) var isDeleted = false
    private(set) var actionErrorMessage: String?

    private var latestRequest = LatestRequest()
    private let studentId: Int
    private let studentService: any StudentDirectoryService

    init(
        student: DirectoryStudent,
        studentService: any StudentDirectoryService
    ) {
        self.studentId = student.id
        self.state = .loaded(student)
        self.studentService = studentService
    }

    func dismissError() {
        actionErrorMessage = nil
    }

    var deleteConfirmationTitle: String {
        let name = state.value?.fullName ?? "Tələbə"
        return "\(name) tamamilə silinsin? Qrupdan çıxarılacaq, qiymətləri, davamiyyəti və balları da silinəcək. Bu əməliyyat geri qaytarılmır."
    }

    // MARK: - Load

    func load() async {
        let request = latestRequest.start()

        do {
            let student = try await studentService.fetchStudent(id: studentId)

            if latestRequest.isCurrent(request) {
                state = .loaded(student)
            }
        } catch is CancellationError {
        } catch {
            if state.value == nil && latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }

    // MARK: - Delete

    func requestDelete() {
        isDeleteConfirmationPresented = true
    }

    func delete() async {
        guard !isDeleting, !isDeleted else {
            return
        }

        actionErrorMessage = nil
        isDeleting = true

        defer {
            isDeleting = false
        }

        do {
            try await studentService.deleteStudent(id: studentId)
            // A load still on its way must not show the deleted student again.
            _ = latestRequest.start()
            isDeleted = true
        } catch {
            actionErrorMessage = error.localizedDescription
        }
    }
}
