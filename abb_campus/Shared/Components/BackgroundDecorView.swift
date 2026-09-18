import SwiftUI

struct BackgroundDecorView: View {

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                topLeftDecoration(geometry: geometry)
                bottomRightDecoration(geometry: geometry)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func topLeftDecoration(
        geometry: GeometryProxy
    ) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.07))
                .frame(width: 330, height: 330)
                .offset(
                    x: -geometry.size.width * 0.55,
                    y: -geometry.size.height * 0.22
                )

            Circle()
                .fill(Color.blue.opacity(0.035))
                .frame(width: 420, height: 420)
                .offset(
                    x: -geometry.size.width * 0.62,
                    y: -geometry.size.height * 0.27
                )
        }
    }

    private func bottomRightDecoration(
        geometry: GeometryProxy
    ) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.055))
                .frame(width: 390, height: 390)
                .offset(
                    x: geometry.size.width * 0.67,
                    y: geometry.size.height * 0.53
                )

            Circle()
                .fill(Color.blue.opacity(0.03))
                .frame(width: 470, height: 470)
                .offset(
                    x: geometry.size.width * 0.73,
                    y: geometry.size.height * 0.57
                )
        }
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
            .ignoresSafeArea()

        BackgroundDecorView()
    }
}
