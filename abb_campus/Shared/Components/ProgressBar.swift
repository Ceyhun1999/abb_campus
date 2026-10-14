import SwiftUI

struct ProgressBar: View {

    let color: Color
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.progressTrack)

                Capsule()
                    .fill(color)
                    .frame(
                        width: geometry.size.width * clampedProgress
                    )
            }
        }
        .frame(height: 8)
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
}

#Preview {
    ProgressBar(color: .gradeGreen, progress: 0.7)
        .padding()
}
