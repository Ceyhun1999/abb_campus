import SwiftUI

/// Deactivates (red) or reactivates (primary) an account.
struct StatusActionButton: View {

    let title: String
    let isActive: Bool
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        if isActive {
            Button(action: action) {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(title)
                            .font(.manropeSemiBold(17))
                    }
                }
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        } else {
            PrimaryButton(title: title, isLoading: isLoading, action: action)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        StatusActionButton(title: "Deaktiv et", isActive: true, isLoading: false) {}
        StatusActionButton(title: "Aktiv et", isActive: false, isLoading: false) {}
    }
    .padding()
}
