import Foundation
import Observation

struct GroupFormOptions: Equatable {
    let courses: [Course]
    let teachers: [Teacher]
}

@MainActor
@Observable
final class GroupFormViewModel {

    static let maxNameLength = 20

    var name = ""
    var selectedCourseId: Int? {
        didSet {
            removeStaffFromOtherCourses()
        }
    }
    var selectedTeacherId: Int?
    private(set) var selectedMentorIds: Set<Int> = []
    var startDate = Date()
    var endDate: Date?
    var isActive = true
    private(set) var removedInactiveStaff: [String] = []
    private var initialSnapshot: Snapshot?

    private(set) var options: ViewState<GroupFormOptions> = .idle
    private(set) var isSaving = false
    private(set) var errorMessage: String?
    /// The server's question when new dates would leave lessons outside the group.
    private(set) var scheduleConfirmation: String?

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
            selectedTeacherId = group.teacher.flatMap { $0.isInactive ? nil : $0.id }
            selectedMentorIds = Set((group.mentors ?? []).filter { !$0.isInactive }.map(\.id))
            removedInactiveStaff = group.inactiveStaff.map(\.fullName)
            startDate = group.startDate.flatMap(DateFormatting.date(fromAPI:)) ?? Date()
            endDate = group.endDate.flatMap(DateFormatting.date(fromAPI:))
            isActive = group.isActive
        }

        initialSnapshot = snapshot
    }

    func dismissError() {
        errorMessage = nil
    }

    // MARK: - Changes

    private struct Snapshot: Equatable {
        let name: String
        let courseId: Int?
        let teacherId: Int?
        let mentorIds: Set<Int>
        let startDate: String
        let endDate: String?
        let isActive: Bool
    }

    private var snapshot: Snapshot {
        Snapshot(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            courseId: selectedCourseId,
            teacherId: selectedTeacherId,
            mentorIds: selectedMentorIds,
            startDate: DateFormatting.apiString(from: startDate),
            endDate: endDate.map(DateFormatting.apiString(from:)),
            isActive: isActive
        )
    }

    var hasChanges: Bool {
        snapshot != initialSnapshot
    }

    func enforceNameLimit() {
        if name.count > Self.maxNameLength {
            name = String(name.prefix(Self.maxNameLength))
        }
    }

    var nameCounter: String {
        "\(name.count)/\(Self.maxNameLength)"
    }

    var isEditing: Bool {
        editingGroup != nil
    }

    var hasCourse: Bool {
        selectedCourseId != nil
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

    static let maxMentors = 2

    func canSelectMentor(_ mentor: Teacher) -> Bool {
        isMentorSelected(mentor) || selectedMentorIds.count < Self.maxMentors
    }

    func toggleMentor(_ mentor: Teacher) {
        if selectedMentorIds.contains(mentor.id) {
            selectedMentorIds.remove(mentor.id)
        } else if canSelectMentor(mentor) {
            selectedMentorIds.insert(mentor.id)
        }
    }

    private var courseStaff: [Teacher] {
        guard let options = options.value,
              let course = options.courses.first(where: { $0.id == selectedCourseId }) else {
            return []
        }

        return options.teachers
            .filter { $0.isActive && $0.specialty == course.name }
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

            options = .loaded(GroupFormOptions(courses: try await courses, teachers: try await teachers))
        } catch is CancellationError {
            options = .idle
        } catch {
            options = .failed(error.localizedDescription)
        }
    }

    // MARK: - Save

    /// Saves again, agreeing that lessons outside the new dates are removed.
    func confirmScheduleChanges() async -> StudyGroup? {
        scheduleConfirmation = nil
        return await save(confirmScheduleChanges: true)
    }

    func dismissScheduleConfirmation() {
        scheduleConfirmation = nil
    }

    func save(confirmScheduleChanges: Bool = false) async -> StudyGroup? {
        guard !isSaving else {
            return nil
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            errorMessage = ValidationMessage.emptyGroupName
            return nil
        }

        guard trimmedName.count <= Self.maxNameLength else {
            errorMessage = ValidationMessage.longGroupName
            return nil
        }

        guard let courseId = selectedCourseId else {
            errorMessage = ValidationMessage.courseNotSelected
            return nil
        }

        guard let endDate else {
            errorMessage = ValidationMessage.endDateNotSelected
            return nil
        }

        guard Calendar.current.startOfDay(for: endDate) >= Calendar.current.startOfDay(for: startDate) else {
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
            endDate: DateFormatting.apiString(from: endDate),
            isActive: isActive,
            confirmScheduleChanges: confirmScheduleChanges
        )

        do {
            if let editingGroup {
                return try await groupService.updateGroup(id: editingGroup.id, request)
            }

            return try await groupService.createGroup(request)
        } catch NetworkError.serverError(statusCode: 409, let message) {
            scheduleConfirmation = message
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
