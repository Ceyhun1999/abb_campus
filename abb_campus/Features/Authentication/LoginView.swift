import SwiftUI

struct LoginView: View {

    let icon: String
    let title: String
    let subtitle: String

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            LoginBackgroundDecorView()

            VStack(spacing: 0) {
                headerView

                loginFieldsView
                    .padding(.top, 36)

                forgotPasswordButton
                    .padding(.top, 14)

                loginButton
                    .padding(.top, 28)

                dividerView
                    .padding(.top, 28)

                Spacer()

                termsView
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            AppLogoView()
                .padding(.top, 32)

            roleIconView
                .padding(.top, 30)

            Text(title)
                .font(.custom("Manrope-Bold", size: 34))
                .tracking(-0.5)
                .padding(.top, 22)

            Text(subtitle)
                .font(.custom("Manrope-Regular", size: 18))
                .foregroundStyle(.secondary)
                .padding(.top, 6)
        }
    }

    // MARK: - Role Icon

    private var roleIconView: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 116, height: 116)

            Image(systemName: icon)
                .font(.system(size: 46, weight: .semibold))
                .foregroundStyle(.blue)
        }
    }

    // MARK: - Login Fields

    private var loginFieldsView: some View {
        VStack(spacing: 14) {
            AuthTextField(
                icon: "envelope",
                placeholder: "E-poçt",
                text: $email,
                keyboardType: .emailAddress
            )

            AuthTextField(
                icon: "lock",
                placeholder: "Şifrə",
                text: $password,
                isSecure: true
            )
        }
    }

    // MARK: - Forgot Password

    private var forgotPasswordButton: some View {
        Button {
            print("Forgot password")
        } label: {
            Text("Şifrəni unutmusunuz?")
                .font(.custom("Manrope-SemiBold", size: 15))
                .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .buttonStyle(.plain)
    }

    // MARK: - Login Button

    private var loginButton: some View {
        Button {
            print("Login")
        } label: {
            Text("Daxil ol")
                .font(.custom("Manrope-SemiBold", size: 17))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(.blue)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Divider

    private var dividerView: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 1)

            Text("və ya")
                .font(.custom("Manrope-Regular", size: 15))
                .foregroundStyle(.secondary)

            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 1)
        }
    }

    // MARK: - Terms

    private var termsView: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.blue)

            Text(
                "Daxil olaraq ABB Campus istifadə şərtlərini qəbul etmiş olursunuz."
            )
            .font(.custom("Manrope-Regular", size: 14))
            .foregroundStyle(.secondary)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .padding(16)
        .background(
            Color.blue.opacity(0.06)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

#Preview {
    LoginView(
        icon: "graduationcap.fill",
        title: "Tələbə girişi",
        subtitle: "Hesabınıza daxil olun"
    )
}
