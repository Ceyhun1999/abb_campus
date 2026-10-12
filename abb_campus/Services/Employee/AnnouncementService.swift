import Foundation

protocol AnnouncementService {
    func fetchAnnouncements() async throws -> [Announcement]
    func createAnnouncement(_ request: CreateAnnouncementRequest) async throws -> Announcement
}

final class DefaultAnnouncementService: AnnouncementService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    func fetchAnnouncements() async throws -> [Announcement] {
        let response: PaginatedResponse<Announcement> = try await networkService.request(
            EmployeeEndpoint.announcements
        )

        return response.data
    }

    func createAnnouncement(_ request: CreateAnnouncementRequest) async throws -> Announcement {
        let response: APIResponse<Announcement> = try await networkService.request(
            EmployeeEndpoint.createAnnouncement(request)
        )

        return response.data
    }
}
