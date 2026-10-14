import SwiftUI

struct ChangePasswordView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ChangePasswordViewModel

    init(viewModel: ChangePasswordViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    Text("Yeni şifrə ən azı 8 simvoldan ibarət olmalıdır. Dəyişiklikdən sonra digər cihazlardakı sessiyalar bağlanacaq.")
                        .font(.manropeRegular(14))
                        .foregroundStyle(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 6)

                    AuthTextField(
                        icon: "lock",
                        placeholder: "Cari şifrə",
                        text: $viewModel.currentPassword,
                        isSecure: true,
                        textContentType: .password,
                        accessibilityID: "change_password_current"
                    )

                    AuthTextField(
                        icon: "lock.badge.plus",
                        placeholder: "Yeni şifrə",
                        text: $viewModel.newPassword,
                        isSecure: true,
                        textContentType: .newPassword,
                        accessibilityID: "change_password_new"
                    )

                    AuthTextField(
                        icon: "lock.rotation",
                        placeholder: "Yeni şifrəni təkrarlayın",
                        text: $viewModel.passwordConfirmation,
                        isSecure: true,
                        textContentType: .newPassword,
                        accessibilityID: "change_password_confirm"
                    )

                    PrimaryButton(title: "Yadda saxla", isLoading: viewModel.isSaving) {
                        Task {
                            await viewModel.save()
                        }
                    }
                    .padding(.top, 10)
                    .accessibilityIdentifier("change_password_save")
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 20)
            }
            .background(.appBackground)
            .navigationTitle("Şifrəni dəyiş")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ləğv et") {
                        dismiss()
                    }
                }
            }
            .errorAlert(viewModel.errorMessage, onDismiss: viewModel.dismissError)
            .alert("Şifrə dəyişdirildi", isPresented: .constant(viewModel.isCompleted)) {
                Button("Bağla") {
                    dismiss()
                }
            } message: {
                Text("Növbəti girişdə yeni şifrədən istifadə edin.")
            }
        }
    }
}
