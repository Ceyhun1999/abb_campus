import Foundation
import Observation

@MainActor
@Observable
final class EmployeeHomeViewModel {

    private let content = LoadableValue<DashboardSummary>(keepsValueOnFailure: false)

    private let authenticationState: AuthenticationState
    private let dashboardService: any EmployeeDashboardService

    init(
        authenticationState: AuthenticationState,
        dashboardService: any EmployeeDashboardService
    ) {
        self.authenticationState = authenticationState
        self.dashboardService = dashboardService
    }

    var greeting: String {
        guard let firstName = authenticationState.currentUser?.firstName else {
            return "Salam!"
        }

        return "Salam, \(firstName)!"
    }

    var state: ViewState<DashboardSummary> {
        content.state
    }

    func load() async {
        await content.load {
            try await dashboardService.fetchDashboard()
        }
    }
}
