import Foundation

protocol AnnouncementService {
    func fetchAnnouncements(page: Int) async throws -> Page<Announcement>
    func createAnnouncement(_ request: CreateAnnouncementRequest) async throws -> Announcement
}

final class DefaultAnnouncementService: AnnouncementService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    func fetchAnnouncements(page: Int) async throws -> Page<Announcement> {
        let response: PaginatedResponse<Announcement> = try await networkService.request(
            EmployeeEndpoint.announcements(page: page)
        )

        return response.page
    }

    func createAnnouncement(_ request: CreateAnnouncementRequest) async throws -> Announcement {
        let response: APIResponse<Announcement> = try await networkService.request(
            EmployeeEndpoint.createAnnouncement(request)
        )

        return response.data
    }
}
