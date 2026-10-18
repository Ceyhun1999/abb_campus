import SwiftUI

/// "Salam, Aysel!" with a line below and the user's avatar: the top of every home screen.
struct GreetingHeader: View {

    let greeting: String
    let subtitle: String
    let user: User?
    let identifier: String
    var titleSize: CGFloat = 24
    var subtitleSize: CGFloat = 15
    var avatarSize: CGFloat = 52

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.manropeBold(titleSize))
                    .foregroundStyle(.textPrimary)
                    .accessibilityIdentifier(identifier)

                Text(subtitle)
                    .font(.manropeRegular(subtitleSize))
                    .foregroundStyle(.textSecondary)
            }

            Spacer()

            if let user {
                AvatarView(firstName: user.firstName, lastName: user.lastName, size: avatarSize)
            }
        }
    }
}
