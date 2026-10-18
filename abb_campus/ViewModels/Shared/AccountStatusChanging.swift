import Foundation
import Observation

/// A screen that deactivates or reactivates an account after the user confirms.
@MainActor
protocol AccountStatusChanging: AnyObject, Observable {
    var isStatusConfirmationPresented: Bool { get set }
    var statusConfirmationTitle: String { get }
    var statusActionTitle: String { get }
    var actionErrorMessage: String? { get }

    func toggleStatus() async
    func dismissError()
}
