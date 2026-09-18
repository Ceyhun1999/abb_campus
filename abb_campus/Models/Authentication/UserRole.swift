import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case student
    case teacher
    case employee

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .student:
            return "Tələbə"

        case .teacher:
            return "Müəllim"

        case .employee:
            return "İşçi"
        }
    }

    var subtitle: String {
        switch self {
        case .student:
            return "Qiymətlərə, dərs cədvəlinə və kurslara bax"

        case .teacher:
            return "Qrupları, tələbələri və qiymətləri idarə et"

        case .employee:
            return "Qrupları və istifadəçiləri idarə et"
        }
    }

    var icon: String {
        switch self {
        case .student:
            return "graduationcap.fill"

        case .teacher:
            return "person.crop.rectangle"

        case .employee:
            return "briefcase.fill"
        }
    }
}
