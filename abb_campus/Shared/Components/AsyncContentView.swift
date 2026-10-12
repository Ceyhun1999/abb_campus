import SwiftUI

/// Renders loading, error and empty states for a `ViewState`,
/// so every screen handles them the same way.
struct AsyncContentView<Value, Content: View>: View {

    let state: ViewState<Value>
    var isEmpty: (Value) -> Bool = { _ in false }
    var emptyTitle: String = "Məlumat yoxdur"
    var emptyMessage: String = ""
    var emptyIcon: String = "tray"
    let retry: () async -> Void
    @ViewBuilder let content: (Value) -> Content

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("loading_view")

        case .failed(let message):
            ContentUnavailableView {
                Label("Xəta baş verdi", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Yenidən cəhd et") {
                    Task {
                        await retry()
                    }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("retry_button")
            }

        case .loaded(let value):
            if isEmpty(value) {
                ContentUnavailableView(
                    emptyTitle,
                    systemImage: emptyIcon,
                    description: Text(emptyMessage)
                )
                .accessibilityIdentifier("empty_view")
            } else {
                content(value)
            }
        }
    }
}
