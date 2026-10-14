import SwiftUI

struct ForgotPasswordView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ForgotPasswordViewModel

    init(viewModel: ForgotPasswordViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    StepHeaderView(step: viewModel.step)

                    stepContent

                    PrimaryButton(
                        title: viewModel.step.buttonTitle,
                        isLoading: viewModel.isLoading
                    ) {
                        if viewModel.step == .completed {
                            dismiss()
                        } else {
                            Task {
                                await viewModel.submit()
                            }
                        }
                    }
                    .accessibilityIdentifier("forgot_password_submit")
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.top, 24)
                .animation(.default, value: viewModel.step)
            }
            .scrollDismissesKeyboard(.interactively)
            .errorAlert(viewModel.errorMessage, onDismiss: viewModel.dismissError)
            .navigationTitle("Şifrənin bərpası")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
        .presentationDragIndicator(.visible)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Bağla") {
                dismiss()
            }
        }

        if viewModel.step == .code || viewModel.step == .newPassword {
            ToolbarItem(placement: .navigation) {
                Button {
                    viewModel.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Geri")
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        @Bindable var viewModel = viewModel

        switch viewModel.step {
        case .email:
            AuthTextField(
                icon: "envelope",
                placeholder: "E-poçt",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                accessibilityID: "forgot_password_email"
            )

        case .code:
            AuthTextField(
                icon: "number",
                placeholder: "6 rəqəmli kod",
                text: $viewModel.code,
                keyboardType: .numberPad,
                textContentType: .oneTimeCode,
                accessibilityID: "forgot_password_code"
            )

        case .newPassword:
            VStack(spacing: 14) {
                AuthTextField(
                    icon: "lock",
                    placeholder: "Yeni şifrə",
                    text: $viewModel.newPassword,
                    isSecure: true,
                    textContentType: .newPassword,
                    accessibilityID: "forgot_password_new"
                )

                AuthTextField(
                    icon: "lock.rotation",
                    placeholder: "Şifrəni təkrarlayın",
                    text: $viewModel.passwordConfirmation,
                    isSecure: true,
                    textContentType: .newPassword,
                    accessibilityID: "forgot_password_confirm"
                )
            }

        case .completed:
            EmptyView()
        }
    }
}

private struct StepHeaderView: View {

    let step: ForgotPasswordViewModel.Step

    var body: some View {
        VStack(spacing: 14) {
            IconCircleView(
                systemName: step.icon,
                diameter: 96,
                iconSize: 38,
                tint: step == .completed ? .green : .blue
            )

            Text(step.title)
                .font(.manropeBold(24))
                .multilineTextAlignment(.center)

            Text(step.message)
                .font(.manropeRegular(16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

private extension ForgotPasswordViewModel.Step {

    var icon: String {
        switch self {
        case .email: return "envelope.badge"
        case .code: return "number.circle"
        case .newPassword: return "lock.rotation"
        case .completed: return "checkmark.seal.fill"
        }
    }

    var title: String {
        switch self {
        case .email: return "Şifrəni unutmusunuz?"
        case .code: return "Kodu daxil edin"
        case .newPassword: return "Yeni şifrə"
        case .completed: return "Şifrə yeniləndi"
        }
    }

    var message: String {
        switch self {
        case .email:
            return "E-poçtunuzu daxil edin, sizə 6 rəqəmli bərpa kodu göndərəcəyik."
        case .code:
            return "E-poçtunuza göndərilən 6 rəqəmli kodu daxil edin."
        case .newPassword:
            return "Minimum 8 simvoldan ibarət yeni şifrə təyin edin."
        case .completed:
            return "İndi yeni şifrənizlə daxil ola bilərsiniz."
        }
    }

    var buttonTitle: String {
        switch self {
        case .email: return "Kod göndər"
        case .code: return "Təsdiqlə"
        case .newPassword: return "Şifrəni yenilə"
        case .completed: return "Girişə qayıt"
        }
    }
}

#Preview {
    ForgotPasswordView(
        viewModel: ForgotPasswordViewModel(
            passwordResetService: DefaultPasswordResetService()
        )
    )
}
