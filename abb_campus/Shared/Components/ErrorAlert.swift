import SwiftUI

struct ErrorAlertModifier: ViewModifier {

    let message: String?
    let onDismiss: () -> Void

    @State private var isPresented = false
    @State private var shownMessage = ""

    func body(content: Content) -> some View {
        content
            .onChange(of: message) { _, newValue in
                guard let newValue else {
                    return
                }

                shownMessage = newValue
                isPresented = true
            }
            .alert("Xəta", isPresented: $isPresented) {
                Button("Bağla", role: .cancel) {
                    onDismiss()
                }
            } message: {
                Text(shownMessage)
            }
    }
}

extension View {

    func errorAlert(_ message: String?, onDismiss: @escaping () -> Void) -> some View {
        modifier(ErrorAlertModifier(message: message, onDismiss: onDismiss))
    }
}
