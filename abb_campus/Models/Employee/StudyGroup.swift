import Foundation

struct Course: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
}

// MARK: - Study Group

struct StudyGroup: Decodable, Identifiable, Hashable {

    struct TeacherReference: Decodable, Hashable {
        let id: Int
        let firstName: String
        let lastName: String
        var isActive: Bool?

        var fullName: String {
            "\(firstName) \(lastName)"
        }

        var isInactive: Bool {
            isActive == false
        }
    }

    let id: Int
    let name: String
    let course: Course?
    let teacher: TeacherReference?
    let mentors: [TeacherReference]?

    var inactiveStaff: [TeacherReference] {
        ([teacher].compactMap { $0 } + (mentors ?? [])).filter(\.isInactive)
    }
    let startDate: String?
    let endDate: String?
    let isActive: Bool
    let studentsCount: Int?
    let progress: Int?
}

struct GroupStudent: Decodable, Identifiable, Hashable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

struct GroupFormRequest: Encodable, Equatable {
    let name: String
    let courseId: Int
    let teacherId: Int?
    let mentorIds: [Int]
    let startDate: String
    let endDate: String
    let isActive: Bool
    /// Sent after the user agrees to remove lessons that fall outside the new dates.
    var confirmScheduleChanges = false

    enum CodingKeys: String, CodingKey {
        case name, courseId, teacherId, mentorIds, startDate, endDate, isActive, confirmScheduleChanges
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(courseId, forKey: .courseId)
        try container.encode(teacherId, forKey: .teacherId)
        try container.encode(mentorIds, forKey: .mentorIds)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(isActive, forKey: .isActive)

        if confirmScheduleChanges {
            try container.encode(true, forKey: .confirmScheduleChanges)
        }
    }
}

struct ImportResult: Decodable, Equatable {

    struct RowError: Decodable, Equatable, Identifiable {
        let row: Int
        let email: String?
        let message: String

        var id: Int { row }
    }

    let imported: Int
    let skipped: Int
    let errors: [RowError]
    /// Schedule import: the dates the file covered and how many old lessons it removed there.
    var from: String?
    var to: String?
    var removed: Int?

    var isRejected: Bool {
        !errors.isEmpty
    }
}
