import SwiftUI

struct AuthTextField: View {

    let icon: String
    let placeholder: String

    @Binding var text: String

    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    @State private var isPasswordVisible = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .frame(width: 24)

            inputField

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
        if isSecure && !isPasswordVisible {
            SecureField(placeholder, text: $text)
                .font(.custom("Manrope-Regular", size: 17))
        } else {
            TextField(placeholder, text: $text)
                .font(.custom("Manrope-Regular", size: 17))
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
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
