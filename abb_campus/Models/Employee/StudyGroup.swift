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

struct CreateGroupRequest: Encodable, Equatable {
    let name: String
    let courseId: Int
    let teacherId: Int?
    let startDate: String
    let endDate: String?
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
