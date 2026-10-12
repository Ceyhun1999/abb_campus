import Foundation

protocol EmployeeDashboardService {
    func fetchDashboard() async throws -> DashboardSummary
}

final class DefaultEmployeeDashboardService: EmployeeDashboardService {

    private let networkService: any NetworkService

    init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    func fetchDashboard() async throws -> DashboardSummary {
        let response: APIResponse<DashboardSummary> = try await networkService.request(
            EmployeeEndpoint.dashboard
        )

        return response.data
    }
}
