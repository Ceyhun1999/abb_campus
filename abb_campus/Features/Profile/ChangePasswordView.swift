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
            Form {
                Section {
                    SecureField("Cari şifrə", text: $viewModel.currentPassword)
                        .textContentType(.password)
                        .accessibilityIdentifier("change_password_current")
                }

                Section {
                    SecureField("Yeni şifrə", text: $viewModel.newPassword)
                        .textContentType(.newPassword)
                        .accessibilityIdentifier("change_password_new")

                    SecureField("Yeni şifrəni təkrarlayın", text: $viewModel.passwordConfirmation)
                        .textContentType(.newPassword)
                        .accessibilityIdentifier("change_password_confirm")
                } footer: {
                    Text("Ən azı 8 simvol. Dəyişiklikdən sonra digər cihazlardakı sessiyalar bağlanacaq.")
                }
            }
            .font(.manropeRegular(16))
            .navigationTitle("Şifrəni dəyiş")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ləğv et") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button("Yadda saxla") {
                            Task {
                                await viewModel.save()
                            }
                        }
                        .accessibilityIdentifier("change_password_save")
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
