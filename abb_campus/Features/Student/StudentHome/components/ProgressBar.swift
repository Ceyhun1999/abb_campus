import SwiftUI

struct ProgressBar: View {
    
    let color: Color
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(
                        Color(
                            red: 240 / 255,
                            green: 242 / 255,
                            blue: 245 / 255
                        )
                    )

                Capsule()
                    .fill(color)
                    .frame(
                        width: geometry.size.width * progress
                    )
            }
        }
        .frame(height: 8)

    }
}
