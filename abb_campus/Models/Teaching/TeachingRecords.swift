import Foundation

// MARK: - Attendance

struct GroupAttendanceSummary: Decodable, Equatable {

    struct StudentRow: Decodable, Equatable, Identifiable {
        let studentId: Int
        let fullName: String
        let email: String
        let present: Int
        let late: Int
        let absent: Int
        let excused: Int
        let total: Int
        let percentage: Int?

        var id: Int { studentId }
    }

    let month: String
    let dates: [String]
    let students: [StudentRow]
}

// MARK: - Scores

enum AssessmentKind: String, Decodable, Hashable {
    case task
    case exam
}

struct GroupAssessment: Decodable, Equatable, Identifiable {

    struct Score: Decodable, Equatable, Identifiable {
        let studentId: Int
        let studentName: String
        let score: Double

        var id: Int { studentId }
    }

    let id: Int
    let kind: AssessmentKind
    let title: String
    let month: String
    let examId: Int?
    let maxScore: Int
    let average: Double?
    let scores: [Score]
}

struct StudentAssessment: Decodable, Equatable, Identifiable {
    let id: Int
    let kind: AssessmentKind
    let title: String
    let month: String
    let examDate: String?
    let score: Double
    let maxScore: Int
}

// MARK: - Requests

struct CancelLessonRequest: Encodable, Equatable {
    let reason: CancelReason
    let note: String?
}

struct ExamFormRequest: Encodable, Equatable {
    let title: String
    let date: String
    let startsAt: String
    let endsAt: String
    let room: String?
}
