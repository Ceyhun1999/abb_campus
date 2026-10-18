import SwiftUI

struct LoginView: View {

    @Environment(AuthenticationState.self) private var authenticationState
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        LoginContentView(
            viewModel: LoginViewModel(
                authenticationState: authenticationState,
                authService: dependencies.authService,
                preferences: dependencies.preferences
            )
        )
    }
}

private struct LoginContentView: View {

    @Environment(\.dependencies) private var dependencies

    @State private var viewModel: LoginViewModel

    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    init(viewModel: LoginViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            Color.screenBackground
                .ignoresSafeArea()

            BackgroundDecorView(style: .login)

            ScrollView {
                VStack(spacing: 0) {
                    headerView

                    loginFieldsView
                        .padding(.top, 36)

                    forgotPasswordButton
                        .padding(.top, 14)

                    PrimaryButton(
                        title: "Daxil ol",
                        isLoading: viewModel.isLoading
                    ) {
                        login()
                    }
                    .accessibilityIdentifier("login_button")
                    .padding(.top, 28)

                    termsView
                        .padding(.top, 40)
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .errorAlert(viewModel.errorMessage, onDismiss: viewModel.dismissError)
        .sheet(isPresented: $viewModel.isForgotPasswordPresented) {
            ForgotPasswordView(
                viewModel: ForgotPasswordViewModel(
                    email: viewModel.email,
                    passwordResetService: dependencies.passwordResetService
                )
            )
        }
    }

    private func login() {
        focusedField = nil

        Task {
            await viewModel.login()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            AppLogoView()
                .padding(.top, 32)

            IconCircleView(
                systemName: viewModel.selectedRole?.icon ?? "person.fill",
                diameter: 116,
                iconSize: 46
            )
            .padding(.top, 30)

            Text(viewModel.selectedRole?.loginTitle ?? "")
                .font(.manropeBold(34))
                .tracking(-0.5)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .padding(.top, 22)
                .accessibilityIdentifier("login_title")

            Text("Hesabınıza daxil olun")
                .font(.manropeRegular(18))
                .foregroundStyle(.secondary)
                .padding(.top, 6)
        }
    }

    // MARK: - Login Fields

    private var loginFieldsView: some View {
        @Bindable var viewModel = viewModel

        return VStack(spacing: 14) {
            AuthTextField(
                icon: "envelope",
                placeholder: "E-poçt",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                textContentType: .username,
                accessibilityID: "login_email"
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .password
            }

            AuthTextField(
                icon: "lock",
                placeholder: "Şifrə",
                text: $viewModel.password,
                isSecure: true,
                textContentType: .password,
                accessibilityID: "login_password"
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit {
                login()
            }
        }
    }

    // MARK: - Forgot Password

    private var forgotPasswordButton: some View {
        Button {
            viewModel.showForgotPassword()
        } label: {
            Text("Şifrəni unutmusunuz?")
                .font(.manropeSemiBold(15))
                .foregroundStyle(.blue)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .trailing
        )
        .buttonStyle(.plain)
        .accessibilityIdentifier("forgot_password_button")
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
            .font(.manropeRegular(14))
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

#Preview {
    let dependencies = AppDependencies.live
    let authenticationState = dependencies.makeAuthenticationState()
    authenticationState.selectRole(.student)

    return NavigationStack {
        LoginView()
    }
    .environment(authenticationState)
    .environment(\.dependencies, dependencies)
}
