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

        var fullName: String {
            "\(firstName) \(lastName)"
        }
    }

    let id: Int
    let name: String
    let course: Course?
    let teacher: TeacherReference?
    let mentors: [TeacherReference]?
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
    let endDate: String?
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case name, courseId, teacherId, mentorIds, startDate, endDate, isActive
    }

    // teacherId and endDate are sent as null when empty, so editing can clear them.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(courseId, forKey: .courseId)
        try container.encode(teacherId, forKey: .teacherId)
        try container.encode(mentorIds, forKey: .mentorIds)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(isActive, forKey: .isActive)
    }
}

struct StudentImportResult: Decodable, Equatable {

    struct RowError: Decodable, Equatable, Identifiable {
        let row: Int
        let email: String?
        let message: String

        var id: Int { row }
    }

    let imported: Int
    let skipped: Int
    let errors: [RowError]

    var totalRows: Int {
        imported + skipped
    }
}
