import SwiftUI

struct PersonRow<Trailing: View>: View {

    let firstName: String
    let lastName: String
    let subtitle: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(firstName: firstName, lastName: lastName, size: 40)

            LabeledContent {
                trailing
            } label: {
                Text("\(firstName) \(lastName)")
                    .font(.manropeSemiBold(16))

                Text(subtitle)
            }
        }
    }
}

extension PersonRow where Trailing == EmptyView {

    init(firstName: String, lastName: String, subtitle: String) {
        self.init(firstName: firstName, lastName: lastName, subtitle: subtitle) {
            EmptyView()
        }
    }
}
