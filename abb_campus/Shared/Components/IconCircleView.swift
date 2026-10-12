import SwiftUI

struct IconCircleView: View {

    let systemName: String
    var diameter: CGFloat = 76
    var iconSize: CGFloat = 30
    var tint: Color = .blue

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.08))
                .frame(width: diameter, height: diameter)

            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(tint)
        }
    }
}

#Preview {
    IconCircleView(systemName: "graduationcap.fill")
}
