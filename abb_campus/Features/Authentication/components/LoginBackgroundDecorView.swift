import SwiftUI

struct LoginBackgroundDecorView: View {

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                topRightDecoration(geometry: geometry)
                bottomLeftDecoration(geometry: geometry)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func topRightDecoration(
        geometry: GeometryProxy
    ) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.06))
                .frame(width: 220, height: 220)
                .offset(
                    x: geometry.size.width * 0.55,
                    y: -geometry.size.height * 0.18
                )

            Circle()
                .fill(Color.blue.opacity(0.03))
                .frame(width: 280, height: 280)
                .offset(
                    x: geometry.size.width * 0.60,
                    y: -geometry.size.height * 0.22
                )
        }
    }

    private func bottomLeftDecoration(
        geometry: GeometryProxy
    ) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.05))
                .frame(width: 210, height: 210)
                .offset(
                    x: -geometry.size.width * 0.55,
                    y: geometry.size.height * 0.50
                )

            Circle()
                .fill(Color.blue.opacity(0.025))
                .frame(width: 270, height: 270)
                .offset(
                    x: -geometry.size.width * 0.60,
                    y: geometry.size.height * 0.55
                )
        }
    }
}
