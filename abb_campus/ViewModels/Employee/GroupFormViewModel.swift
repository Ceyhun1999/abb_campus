import Foundation
import Observation

struct GroupFormOptions: Equatable {
    let courses: [Course]
    let teachers: [Teacher]
}

@MainActor
@Observable
final class GroupFormViewModel {

    var name = ""
    var selectedCourseId: Int? {
        didSet {
            removeStaffFromOtherCourses()
        }
    }
    var selectedTeacherId: Int?
    private(set) var selectedMentorIds: Set<Int> = []
    var startDate = Date()
    var hasEndDate = true
    var endDate = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    var isActive = true

    private(set) var options: ViewState<GroupFormOptions> = .idle
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    let editingGroup: StudyGroup?
    private let groupService: any GroupService
    private let teacherService: any TeacherService

    init(
        group: StudyGroup? = nil,
        groupService: any GroupService,
        teacherService: any TeacherService
    ) {
        self.editingGroup = group
        self.groupService = groupService
        self.teacherService = teacherService

        if let group {
            name = group.name
            selectedCourseId = group.course?.id
            selectedTeacherId = group.teacher?.id
            selectedMentorIds = Set(group.mentors?.map(\.id) ?? [])
            startDate = group.startDate.flatMap(DateFormatting.date(fromAPI:)) ?? Date()
            hasEndDate = group.endDate != nil
            endDate = group.endDate.flatMap(DateFormatting.date(fromAPI:)) ?? endDate
            isActive = group.isActive
        }
    }

    var isEditing: Bool {
        editingGroup != nil
    }

    var title: String {
        isEditing ? "Redaktə" : "Yeni qrup"
    }

    var saveTitle: String {
        isEditing ? "Yadda saxla" : "Yarat"
    }

    // MARK: - Staff

    var availableTeachers: [Teacher] {
        courseStaff.filter { $0.position != .mentor }
    }

    var availableMentors: [Teacher] {
        courseStaff.filter { $0.position == .mentor }
    }

    func isMentorSelected(_ mentor: Teacher) -> Bool {
        selectedMentorIds.contains(mentor.id)
    }

    func toggleMentor(_ mentor: Teacher) {
        if selectedMentorIds.contains(mentor.id) {
            selectedMentorIds.remove(mentor.id)
        } else {
            selectedMentorIds.insert(mentor.id)
        }
    }

    private var courseStaff: [Teacher] {
        guard let options = options.value,
              let course = options.courses.first(where: { $0.id == selectedCourseId }) else {
            return []
        }

        return options.teachers
            .filter { $0.specialty == course.name }
            .sorted { $0.fullName < $1.fullName }
    }

    private func removeStaffFromOtherCourses() {
        guard options.value != nil else {
            return
        }

        if let selectedTeacherId, !availableTeachers.contains(where: { $0.id == selectedTeacherId }) {
            self.selectedTeacherId = nil
        }

        selectedMentorIds = selectedMentorIds.intersection(availableMentors.map(\.id))
    }

    // MARK: - Load

    func loadOptions() async {
        guard options.value == nil else {
            return
        }

        options = .loading

        do {
            async let courses = groupService.fetchCourses()
            async let teachers = teacherService.fetchTeachers(search: "", position: .all, specialty: nil)

            let loaded = GroupFormOptions(courses: try await courses, teachers: try await teachers)
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

        let request = GroupFormRequest(
            name: trimmedName.uppercased(),
            courseId: courseId,
            teacherId: selectedTeacherId,
            mentorIds: selectedMentorIds.sorted(),
            startDate: DateFormatting.apiString(from: startDate),
            endDate: hasEndDate ? DateFormatting.apiString(from: endDate) : nil,
            isActive: isActive
        )

        do {
            if let editingGroup {
                return try await groupService.updateGroup(id: editingGroup.id, request)
            }

            return try await groupService.createGroup(request)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
