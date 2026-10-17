import SwiftUI

struct PrimaryButton: View {

    let title: String
    var isLoading: Bool = false
    var loadingTitle: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(.white)

                        if let loadingTitle {
                            Text(loadingTitle)
                                .font(.manropeSemiBold(17))
                        }
                    }
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
        .allowsHitTesting(!isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Daxil ol") {}
        PrimaryButton(title: "Daxil ol", isLoading: true) {}
    }
    .padding()
}
