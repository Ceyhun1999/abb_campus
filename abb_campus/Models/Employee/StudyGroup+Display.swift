import Foundation

extension StudyGroup.TeacherReference {

    /// "Kamal Əliyev (deaktiv)" for someone who can no longer sign in.
    var displayName: String {
        isInactive ? "\(fullName) (deaktiv)" : fullName
    }
}

extension StudyGroup {

    var teacherText: String {
        teacher?.displayName ?? "Təyin edilməyib"
    }

    /// One mentor per line.
    var mentorsText: String {
        let names = (mentors ?? []).map(\.displayName)
        return names.isEmpty ? "Təyin edilməyib" : names.joined(separator: "\n")
    }

    /// "01.09.2026 – 01.03.2027"
    var periodText: String {
        let start = DateFormatting.displayDate(from: startDate) ?? "—"
        let end = DateFormatting.displayDate(from: endDate) ?? "…"

        return "\(start) – \(end)"
    }

    /// "Tələbə sayı: 6 · Mobile Development iOS"
    var cardSubtitle: String {
        var parts: [String] = []

        if let count = studentsCount {
            parts.append("Tələbə sayı: \(count)")
        }

        if let course = course?.name {
            parts.append(course)
        }

        return parts.joined(separator: " · ")
    }
}
