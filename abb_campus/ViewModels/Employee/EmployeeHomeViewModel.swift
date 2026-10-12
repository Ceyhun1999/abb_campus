import Foundation
import Observation

@MainActor
@Observable
final class EmployeeHomeViewModel {

    private(set) var state: ViewState<DashboardSummary> = .idle

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

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            state = .loaded(try await dashboardService.fetchDashboard())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
