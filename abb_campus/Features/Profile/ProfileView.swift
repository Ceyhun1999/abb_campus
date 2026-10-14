import SwiftUI

struct ProfileView: View {

    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            List {
                PersonHeader(
                    firstName: viewModel.firstName,
                    lastName: viewModel.lastName,
                    subtitle: viewModel.roleTitle
                )

                Section {
                    LabeledContent("E-poçt", value: viewModel.email)
                    LabeledContent("Rol", value: viewModel.roleTitle)
                }

                Section {
                    Button {
                        viewModel.showChangePassword()
                    } label: {
                        Label("Şifrəni dəyiş", systemImage: "key")
                    }
                    .accessibilityIdentifier("change_password_button")
                }

                Section {
                    Button(role: .destructive) {
                        viewModel.requestLogout()
                    } label: {
                        if viewModel.isLoggingOut {
                            ProgressView()
                        } else {
                            Label("Çıxış et", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                    .disabled(viewModel.isLoggingOut)
                    .accessibilityIdentifier("logout_button")
                }
            }
            .font(.manropeRegular(16))
            .navigationTitle("Profil")
            .sheet(isPresented: $viewModel.isChangePasswordPresented) {
                if let changePasswordViewModel = viewModel.changePasswordViewModel {
                    ChangePasswordView(viewModel: changePasswordViewModel)
                }
            }
            .confirmationDialog(
                "Hesabdan çıxmaq istəyirsiniz?",
                isPresented: $viewModel.isLogoutConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button("Çıxış et", role: .destructive) {
                    Task {
                        await viewModel.logout()
                    }
                }
                .accessibilityIdentifier("confirm_logout_button")

                Button("Ləğv et", role: .cancel) {}
            }
        }
    }
}
