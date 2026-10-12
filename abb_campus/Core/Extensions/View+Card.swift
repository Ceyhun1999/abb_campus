import SwiftUI

extension View {

    func cardStyle(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(.cardBackground)
            .clipShape(
                RoundedRectangle(cornerRadius: cornerRadius)
            )
            .shadow(
                color: .black.opacity(0.05),
                radius: 10,
                x: 0,
                y: 4
            )
    }
}
