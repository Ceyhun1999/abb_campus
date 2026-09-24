import SwiftUI

struct LoginView: View {

    @Environment(AuthenticationState.self)
    private var authenticationState

    var body: some View {
        LoginContentView(
            authenticationState: authenticationState
        )
    }
}

private struct LoginContentView: View {

    let authenticationState: AuthenticationState

    @State private var loginVM: LoginViewModel

    init(authenticationState: AuthenticationState) {
        self.authenticationState = authenticationState

        _loginVM = State(
            initialValue: LoginViewModel(
                authenticationState: authenticationState
            )
        )
    }

    var body: some View {
        @Bindable var loginVM = loginVM

        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            LoginBackgroundDecorView()

            VStack(spacing: 0) {
                headerView

                loginFieldsView(
                    email: $loginVM.email,
                    password: $loginVM.password
                )
                .padding(.top, 36)

                errorText

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

    // MARK: - Role

    private var selectedRole: UserRole? {
        authenticationState.selectedRole
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            AppLogoView()
                .padding(.top, 32)

            roleIconView
                .padding(.top, 30)

            Text(selectedRole?.loginTitle ?? "")
                .font(.custom("Manrope-Bold", size: 34))
                .tracking(-0.5)
                .padding(.top, 22)

            Text("Hesabınıza daxil olun")
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

            Image(
                systemName: selectedRole?.icon ?? "person.fill"
            )
            .font(.system(size: 46, weight: .semibold))
            .foregroundStyle(.blue)
        }
    }

    // MARK: - Login Fields

    private func loginFieldsView(
        email: Binding<String>,
        password: Binding<String>
    ) -> some View {
        VStack(spacing: 14) {
            AuthTextField(
                icon: "envelope",
                placeholder: "E-poçt",
                text: email,
                keyboardType: .emailAddress
            )

            AuthTextField(
                icon: "lock",
                placeholder: "Şifrə",
                text: password,
                isSecure: true
            )
        }
    }

    // MARK: - Error

    @ViewBuilder
    private var errorText: some View {
        if let errorMessage = loginVM.errorMessage {
            Text(errorMessage)
                .font(.custom("Manrope-Regular", size: 14))
                .foregroundStyle(.red)
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
                .padding(.top, 8)
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
        .frame(
            maxWidth: .infinity,
            alignment: .trailing
        )
        .buttonStyle(.plain)
    }

    // MARK: - Login Button

    private var loginButton: some View {
        Button {
            Task {
                await loginVM.login()
            }
        } label: {
            Group {
                if loginVM.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Daxil ol")
                        .font(
                            .custom(
                                "Manrope-SemiBold",
                                size: 17
                            )
                        )
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(.blue)
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
        .disabled(loginVM.isLoading)
        .opacity(loginVM.isLoading ? 0.7 : 1)
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
        .background(Color.blue.opacity(0.06))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

