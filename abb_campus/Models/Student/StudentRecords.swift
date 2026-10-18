import Foundation

// MARK: - Attendance

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

// MARK: - Schedule

enum LessonKind: String, Decodable, Hashable {
    case lesson
    case exam
}

enum CancelReason: String, Codable, CaseIterable, Identifiable, Hashable {
    case teacherSick = "teacher_sick"
    case holiday
    case dayOff = "day_off"
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .teacherSick: return "Müəllim xəstədir"
        case .holiday: return "Bayram"
        case .dayOff: return "Qeyri-iş günü"
        case .other: return "Digər səbəb"
        }
    }
}

struct ScheduleLesson: Decodable, Identifiable, Hashable {
    let id: Int
    let title: String
    let date: String
    let startsAt: String
    let endsAt: String
    let room: String?
    let description: String?
    let kind: LessonKind
    let isCancelled: Bool
    let cancelReason: CancelReason?
    let cancelNote: String?
    /// Set in a teacher's schedule, where lessons of several groups are mixed.
    let groupName: String?
    /// For exams: whether the scores are uploaded.
    let hasScores: Bool

    init(
        id: Int,
        title: String,
        date: String,
        startsAt: String,
        endsAt: String,
        room: String?,
        description: String?,
        kind: LessonKind = .lesson,
        isCancelled: Bool = false,
        cancelReason: CancelReason? = nil,
        cancelNote: String? = nil,
        groupName: String? = nil,
        hasScores: Bool = false
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.startsAt = startsAt
        self.endsAt = endsAt
        self.room = room
        self.description = description
        self.kind = kind
        self.isCancelled = isCancelled
        self.cancelReason = cancelReason
        self.cancelNote = cancelNote
        self.groupName = groupName
        self.hasScores = hasScores
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, date, startsAt, endsAt, room, description
        case kind, isCancelled, cancelReason, cancelNote, groupName, hasScores
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(String.self, forKey: .date)
        startsAt = try container.decode(String.self, forKey: .startsAt)
        endsAt = try container.decode(String.self, forKey: .endsAt)
        room = try container.decodeIfPresent(String.self, forKey: .room)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        kind = try container.decodeIfPresent(LessonKind.self, forKey: .kind) ?? .lesson
        isCancelled = try container.decodeIfPresent(Bool.self, forKey: .isCancelled) ?? false
        cancelReason = try container.decodeIfPresent(CancelReason.self, forKey: .cancelReason)
        cancelNote = try container.decodeIfPresent(String.self, forKey: .cancelNote)
        groupName = try container.decodeIfPresent(String.self, forKey: .groupName)
        hasScores = try container.decodeIfPresent(Bool.self, forKey: .hasScores) ?? false
    }

    var timeRange: String {
        "\(startsAt) – \(endsAt)"
    }

    var isExam: Bool {
        kind == .exam
    }

    /// "Bayram" or "Digər səbəb: ..." for a cancelled lesson.
    var cancellationText: String? {
        guard isCancelled else {
            return nil
        }

        let reason = cancelReason?.title ?? "Ləğv edilib"

        guard let note = cancelNote, !note.isEmpty else {
            return reason
        }

        return cancelReason == .other ? note : "\(reason). \(note)"
    }
}
