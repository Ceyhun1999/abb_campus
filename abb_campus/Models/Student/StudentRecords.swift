import Foundation

struct GradesOverview: Decodable, Equatable {
    let modules: [ModuleScore]
    let averageScore: Double
    let overallScore: Double
}

struct ModuleScore: Decodable, Identifiable, Hashable {
    let moduleId: Int
    let moduleName: String
    let totalScore: Double
    let maxScore: Double

    var id: Int { moduleId }

    var progress: Double {
        maxScore > 0 ? totalScore / maxScore : 0
    }
}

struct ModuleGrades: Decodable, Equatable {

    struct ModuleReference: Decodable, Equatable {
        let id: Int
        let name: String
    }

    struct CategoryScore: Decodable, Equatable, Identifiable {
        let category: String
        let score: Double
        let maxScore: Double

        var id: String { category }
    }

    let module: ModuleReference
    let grades: [CategoryScore]
    let totalScore: Double
    let maxScore: Double
}

enum AttendanceStatus: String, Decodable {
    case present
    case absent
    case late
    case excused

    var title: String {
        switch self {
        case .present: return "İştirak edib"
        case .absent: return "Qayıb"
        case .late: return "Gecikib"
        case .excused: return "Üzrlü"
        }
    }
}

struct AttendanceRecord: Decodable, Identifiable, Equatable {
    let id: Int
    let date: String
    let status: AttendanceStatus
    let note: String?
}

struct AttendanceSummary: Decodable, Equatable {
    let records: [AttendanceRecord]
    let totalDays: Int
    let presentDays: Int
    let attendancePercentage: Double
}

struct ScheduleLesson: Decodable, Identifiable, Hashable {
    let id: Int
    let title: String
    let date: String
    let startsAt: String
    let endsAt: String
    let room: String?
    let description: String?

    var timeRange: String {
        "\(startsAt) – \(endsAt)"
    }
}
