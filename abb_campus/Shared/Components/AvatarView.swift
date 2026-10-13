import SwiftUI

struct AvatarView: View {

    let firstName: String
    let lastName: String
    var size: CGFloat = 44

    private static let palette: [Color] = [
        .blue, .indigo, .teal, .orange, .pink, .purple, .green, .cyan
    ]

    var body: some View {
        Text(initials)
            .font(.manropeBold(size * 0.38))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.gradient)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }

    private var initials: String {
        [firstName, lastName]
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }

    // MARK: - Color

    private var color: Color {
        let seed = (firstName + lastName).unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return Self.palette[seed % Self.palette.count]
    }
}

#Preview {
    HStack {
        AvatarView(firstName: "Nihad", lastName: "Məmmədov")
        AvatarView(firstName: "Leyla", lastName: "Həsənli", size: 96)
    }
}
