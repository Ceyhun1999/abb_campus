import Foundation
import Observation

@MainActor
@Observable
final class StudentDetailViewModel {

    var isStatusConfirmationPresented = false
    private(set) var state: ViewState<DirectoryStudent>
    private(set) var isUpdatingStatus = false
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

    // MARK: - Titles

    var statusActionTitle: String {
        state.value?.isActive == true ? "Deaktiv et" : "Aktiv et"
    }

    var statusConfirmationTitle: String {
        state.value?.isActive == true
            ? "Tələbə hesabı deaktiv edilsin? Tələbə tətbiqə daxil ola bilməyəcək."
            : "Tələbə hesabı yenidən aktiv edilsin?"
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

    // MARK: - Status

    func requestStatusChange() {
        isStatusConfirmationPresented = true
    }

    func toggleStatus() async {
        guard !isUpdatingStatus, let student = state.value else {
            return
        }

        actionErrorMessage = nil
        isUpdatingStatus = true

        defer {
            isUpdatingStatus = false
        }

        do {
            try await studentService.setStatus(
                userId: student.id,
                isActive: !student.isActive
            )

            let request = latestRequest.start()
            let updated = try await studentService.fetchStudent(id: student.id)

            if latestRequest.isCurrent(request) {
                state = .loaded(updated)
            }
        } catch {
            actionErrorMessage = error.localizedDescription
        }
    }
}
