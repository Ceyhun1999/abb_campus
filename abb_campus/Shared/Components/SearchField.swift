import SwiftUI

struct SearchField: View {

    let prompt: String
    @Binding var text: String

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(prompt, text: $text)
                .font(.manropeRegular(17))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Axtarışı təmizlə")
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(Color(.tertiarySystemFill), in: Capsule())
        .opacity(isEnabled ? 1 : 0.5)
    }
}
