import Foundation
import Observation

struct CreateGroupOptions: Equatable {
    let courses: [Course]
    let teachers: [Teacher]
}

@MainActor
@Observable
final class CreateGroupViewModel {

    var name = ""
    var selectedCourseId: Int?
    var selectedTeacherId: Int?
    var startDate = Date()
    var hasEndDate = true
    var endDate = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()

    private(set) var options: ViewState<CreateGroupOptions> = .idle
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    private let groupService: any GroupService
    private let teacherService: any TeacherService

    init(groupService: any GroupService, teacherService: any TeacherService) {
        self.groupService = groupService
        self.teacherService = teacherService
    }

    func loadOptions() async {
        guard options.value == nil else {
            return
        }

        options = .loading

        do {
            async let courses = groupService.fetchCourses()
            async let teachers = teacherService.fetchTeachers(search: "")

            let loaded = CreateGroupOptions(courses: try await courses, teachers: try await teachers)
            options = .loaded(loaded)

            if selectedCourseId == nil {
                selectedCourseId = loaded.courses.first?.id
            }
        } catch is CancellationError {
            options = .idle
        } catch {
            options = .failed(error.localizedDescription)
        }
    }

    // MARK: - Save

    func save() async -> StudyGroup? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = ValidationMessage.emptyGroupName
            return nil
        }

        guard let courseId = selectedCourseId else {
            errorMessage = ValidationMessage.courseNotSelected
            return nil
        }

        guard !hasEndDate || Calendar.current.startOfDay(for: endDate) >= Calendar.current.startOfDay(for: startDate) else {
            errorMessage = ValidationMessage.invalidEndDate
            return nil
        }

        errorMessage = nil
        isSaving = true

        defer {
            isSaving = false
        }

        do {
            return try await groupService.createGroup(
                CreateGroupRequest(
                    name: trimmedName.uppercased(),
                    courseId: courseId,
                    teacherId: selectedTeacherId,
                    startDate: DateFormatting.apiString(from: startDate),
                    endDate: hasEndDate ? DateFormatting.apiString(from: endDate) : nil
                )
            )
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
