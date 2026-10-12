import SwiftUI

struct AuthTextField: View {

    let icon: String
    let placeholder: String

    @Binding var text: String

    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var accessibilityID: String?

    @State private var isPasswordVisible = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .frame(width: 24)

            inputField
                .font(.manropeRegular(17))
                .textContentType(textContentType)
                .accessibilityIdentifier(accessibilityID ?? placeholder)

            if isSecure {
                passwordVisibilityButton
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 58)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color.secondary.opacity(0.18),
                    lineWidth: 1
                )
        }
    }

    @ViewBuilder
    private var inputField: some View {
        Group {
            if isSecure && !isPasswordVisible {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .keyboardType(effectiveKeyboardType)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
    }

    /// Passwords are Latin-only, so secure fields always get an ASCII keyboard
    /// even when the device language is Azerbaijani or Russian.
    private var effectiveKeyboardType: UIKeyboardType {
        isSecure ? .asciiCapable : keyboardType
    }

    private var passwordVisibilityButton: some View {
        Button {
            isPasswordVisible.toggle()
        } label: {
            Image(
                systemName: isPasswordVisible
                    ? "eye"
                    : "eye.slash"
            )
            .font(.system(size: 19))
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            isPasswordVisible ? "Şifrəni gizlət" : "Şifrəni göstər"
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        AuthTextField(
            icon: "envelope",
            placeholder: "E-poçt",
            text: .constant("")
        )

        AuthTextField(
            icon: "lock",
            placeholder: "Şifrə",
            text: .constant("Password123!"),
            isSecure: true
        )
    }
    .padding()
}
