import SwiftUI

private struct ImportFlowModifier: ViewModifier {

    @Bindable var flow: ImportFlow

    func body(content: Content) -> some View {
        content
            .navigationDestination(isPresented: $flow.isPresented) {
                if let viewModel = flow.viewModel {
                    GroupImportView(viewModel: viewModel)
                }
            }
            .onChange(of: flow.isPresented) { _, isPresented in
                Task {
                    await flow.presentationChanged(isPresented)
                }
            }
    }
}

extension View {

    /// Pushes the import screen of `flow` and reloads when it closes.
    func importFlow(_ flow: ImportFlow) -> some View {
        modifier(ImportFlowModifier(flow: flow))
    }
}
