import SwiftUI

/// The confirmation before an account is deactivated or reactivated, and the error if it fails.
private struct AccountStatusActions<Model: AccountStatusChanging>: ViewModifier {

    @Bindable var model: Model

    func body(content: Content) -> some View {
        content
            .errorAlert(model.actionErrorMessage, onDismiss: model.dismissError)
            .confirmationDialog(
                model.statusConfirmationTitle,
                isPresented: $model.isStatusConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button(model.statusActionTitle, role: .destructive) {
                    Task {
                        await model.toggleStatus()
                    }
                }

                Button("Ləğv et", role: .cancel) {}
            }
    }
}

extension View {

    func accountStatusActions(_ model: some AccountStatusChanging) -> some View {
        modifier(AccountStatusActions(model: model))
    }
}
