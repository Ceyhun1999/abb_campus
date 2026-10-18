import Foundation
import Observation

/// Opens an import screen and reloads the owner's data when the screen closes.
@MainActor
@Observable
final class ImportFlow {

    var isPresented = false
    private(set) var viewModel: GroupImportViewModel?

    @ObservationIgnored var onFinish: (() async -> Void)?

    func start(_ viewModel: GroupImportViewModel) {
        self.viewModel = viewModel
        isPresented = true
    }

    func presentationChanged(_ isPresented: Bool) async {
        guard !isPresented, viewModel != nil else {
            return
        }

        viewModel = nil
        await onFinish?()
    }
}
