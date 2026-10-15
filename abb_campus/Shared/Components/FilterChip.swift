import SwiftUI

struct FilterChip: View {

    let title: String
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Button(action: onRemove) {
                HStack(spacing: 6) {
                    Text(title)
                        .lineLimit(1)

                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                }
                .font(.manropeSemiBold(13))
                .foregroundStyle(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.12))
                .clipShape(Capsule())
            }
            .accessibilityLabel("\(title) filtrini sil")

            Spacer()
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
        .padding(.bottom, 8)
    }
}
