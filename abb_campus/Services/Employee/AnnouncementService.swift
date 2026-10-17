import Foundation

protocol AnnouncementService {
    func fetchAnnouncements(page: Int) async throws -> Page<Announcement>
    func createAnnouncement(_ request: AnnouncementFormRequest) async throws -> Announcement
    func updateAnnouncement(id: Int, _ request: AnnouncementFormRequest) async throws -> Announcement
    func deleteAnnouncement(id: Int) async throws
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

    func createAnnouncement(_ request: AnnouncementFormRequest) async throws -> Announcement {
        let response: APIResponse<Announcement> = try await networkService.request(
            EmployeeEndpoint.createAnnouncement(request)
        )

        return response.data
    }

    func updateAnnouncement(id: Int, _ request: AnnouncementFormRequest) async throws -> Announcement {
        let response: APIResponse<Announcement> = try await networkService.request(
            EmployeeEndpoint.updateAnnouncement(id: id, request)
        )

        return response.data
    }

    func deleteAnnouncement(id: Int) async throws {
        let _: MessageResponse = try await networkService.request(
            EmployeeEndpoint.deleteAnnouncement(id: id)
        )
    }
}
