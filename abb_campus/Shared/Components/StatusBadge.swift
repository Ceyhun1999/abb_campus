import SwiftUI

struct StatusBadge: View {

    let isActive: Bool
    var activeTitle: String = "Aktiv"
    var inactiveTitle: String = "Deaktiv"

    var body: some View {
        Text(isActive ? activeTitle : inactiveTitle)
            .font(.manropeSemiBold(12))
            .foregroundStyle(isActive ? .green : .red)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background((isActive ? Color.green : Color.red).opacity(0.12))
            .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        StatusBadge(isActive: true)
        StatusBadge(isActive: false)
    }
}
