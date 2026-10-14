import Foundation
import Observation

@MainActor
@Observable
final class StudentDetailViewModel {

    var isStatusConfirmationPresented = false
    private(set) var state: ViewState<DirectoryStudent>
    private(set) var isUpdatingStatus = false
    private(set) var actionErrorMessage: String?

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

    var statusActionTitle: String {
        state.value?.isActive == true ? "Deaktiv et" : "Aktiv et"
    }

    var statusConfirmationTitle: String {
        state.value?.isActive == true
            ? "Tələbə hesabı deaktiv edilsin? Tələbə tətbiqə daxil ola bilməyəcək."
            : "Tələbə hesabı yenidən aktiv edilsin?"
    }

    func load() async {
        do {
            state = .loaded(try await studentService.fetchStudent(id: studentId))
        } catch {
            if state.value == nil {
                state = .failed(error.localizedDescription)
            }
        }
    }

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
            state = .loaded(try await studentService.fetchStudent(id: student.id))
        } catch {
            actionErrorMessage = error.localizedDescription
        }
    }
}
