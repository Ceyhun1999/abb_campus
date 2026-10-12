import SwiftUI

struct BackgroundDecorView: View {

    enum Style {
        case welcome
        case login
    }

    var style: Style = .welcome

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(style.circles) { circle in
                    Circle()
                        .fill(Color.blue.opacity(circle.opacity))
                        .frame(width: circle.size, height: circle.size)
                        .offset(
                            x: geometry.size.width * circle.xFactor,
                            y: geometry.size.height * circle.yFactor
                        )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct DecorCircle: Identifiable {
    let size: CGFloat
    let opacity: Double
    let xFactor: CGFloat
    let yFactor: CGFloat

    var id: String {
        "\(size)-\(xFactor)-\(yFactor)"
    }
}

private extension BackgroundDecorView.Style {

    var circles: [DecorCircle] {
        switch self {
        case .welcome:
            return [
                DecorCircle(size: 330, opacity: 0.07, xFactor: -0.55, yFactor: -0.22),
                DecorCircle(size: 420, opacity: 0.035, xFactor: -0.62, yFactor: -0.27),
                DecorCircle(size: 390, opacity: 0.055, xFactor: 0.67, yFactor: 0.53),
                DecorCircle(size: 470, opacity: 0.03, xFactor: 0.73, yFactor: 0.57)
            ]

        case .login:
            return [
                DecorCircle(size: 220, opacity: 0.06, xFactor: 0.55, yFactor: -0.18),
                DecorCircle(size: 280, opacity: 0.03, xFactor: 0.60, yFactor: -0.22),
                DecorCircle(size: 210, opacity: 0.05, xFactor: -0.55, yFactor: 0.50),
                DecorCircle(size: 270, opacity: 0.025, xFactor: -0.60, yFactor: 0.55)
            ]
        }
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()

        BackgroundDecorView(style: .welcome)
    }
}
