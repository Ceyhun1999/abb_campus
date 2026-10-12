import SwiftUI

struct SectionHeaderView: View {

    let title: String
    var buttonTitle: String = "Hamısına bax"
    let action: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.manropeBold(20))

            Spacer()

            Button {
                action()
            } label: {
                HStack(spacing: 4) {
                    Text(buttonTitle)
                        .font(.manropeRegular(15))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
    }
}
