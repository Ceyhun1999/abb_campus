import SwiftUI

struct StatusToggleButton: View {

    let title: String
    let isActive: Bool
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(role: isActive ? .destructive : nil, action: action) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text(title)
                    .frame(maxWidth: .infinity)
            }
        }
        .disabled(isLoading)
    }
}
