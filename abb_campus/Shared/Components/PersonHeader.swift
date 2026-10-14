import SwiftUI

struct PersonHeader: View {

    let firstName: String
    let lastName: String
    let subtitle: String
    var nameAccessibilityID: String?

    var body: some View {
        Section {
            VStack(spacing: 8) {
                AvatarView(firstName: firstName, lastName: lastName, size: 88)

                Text("\(firstName) \(lastName)")
                    .font(.manropeBold(22))
                    .accessibilityIdentifier(nameAccessibilityID ?? "person_name")

                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
    }
}
