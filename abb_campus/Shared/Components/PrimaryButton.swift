import SwiftUI

struct PrimaryButton: View {

    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.manropeSemiBold(17))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(.blue)
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Daxil ol") {}
        PrimaryButton(title: "Daxil ol", isLoading: true) {}
    }
    .padding()
}
