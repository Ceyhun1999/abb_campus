import SwiftUI

struct ProgressRing: View {

    let progress: Int
    var size: CGFloat = 46

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.15), lineWidth: 5)

            Circle()
                .trim(from: 0, to: CGFloat(progress) / 100)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(progress)%")
                .font(.manropeSemiBold(11))
                .foregroundStyle(.textPrimary)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Proqres \(progress) faiz")
    }
}

#Preview {
    ProgressRing(progress: 76, size: 76)
}
