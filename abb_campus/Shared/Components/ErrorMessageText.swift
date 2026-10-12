import SwiftUI

struct ErrorMessageText: View {

    let message: String?
    var accessibilityID: String = "error_message"

    var body: some View {
        if let message {
            Text(message)
                .font(.manropeRegular(14))
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier(accessibilityID)
        }
    }
}

#Preview {
    ErrorMessageText(message: "E-poçt düzgün formatda deyil.")
}
