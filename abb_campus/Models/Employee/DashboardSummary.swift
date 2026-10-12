import Foundation

struct DashboardSummary: Decodable, Equatable {
    let studentsCount: Int
    let activeStudentsCount: Int
    let newStudentsThisMonth: Int
    let teachersCount: Int
    let groupsCount: Int
    let activeGroupsCount: Int
    let announcementsCount: Int
    let recentAnnouncements: [Announcement]
}
