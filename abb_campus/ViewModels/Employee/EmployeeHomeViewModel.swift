import Foundation
import Observation

@MainActor
@Observable
final class EmployeeHomeViewModel {

    private(set) var state: ViewState<DashboardSummary> = .idle

    private var latestRequest = LatestRequest()

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
        let request = latestRequest.start()

        if state.value == nil {
            state = .loading
        }

        do {
            let summary = try await dashboardService.fetchDashboard()

            if latestRequest.isCurrent(request) {
                state = .loaded(summary)
            }
        } catch is CancellationError {
        } catch {
            if latestRequest.isCurrent(request) {
                state = .failed(error.localizedDescription)
            }
        }
    }
}
