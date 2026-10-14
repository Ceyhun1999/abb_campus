import SwiftUI

struct ProfileView: View {

    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerView

                    infoCard

                    changePasswordButton

                    logoutButton
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 20)
            }
            .background(.appBackground)
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

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 12) {
            Text(viewModel.initials)
                .font(.manropeBold(30))
                .foregroundStyle(.white)
                .frame(width: 96, height: 96)
                .background(.brandBlue)
                .clipShape(Circle())

            Text(viewModel.fullName)
                .font(.manropeBold(22))
                .foregroundStyle(.textPrimary)
                .accessibilityIdentifier("profile_name")

            Text(viewModel.roleTitle)
                .font(.manropeRegular(15))
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Info

    private var infoCard: some View {
        InfoCard {
            InfoRow(
                icon: "envelope",
                title: "E-poçt",
                value: viewModel.email
            )

            InfoDivider()

            InfoRow(
                icon: "person.text.rectangle",
                title: "Rol",
                value: viewModel.roleTitle
            )
        }
    }

    // MARK: - Password

    private var changePasswordButton: some View {
        Button {
            viewModel.showChangePassword()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "key")
                    .font(.system(size: 18))
                    .foregroundStyle(.brandBlue)
                    .frame(width: 24)

                Text("Şifrəni dəyiş")
                    .font(.manropeSemiBold(17))
                    .foregroundStyle(.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, 18)
            .frame(height: 56)
            .cardStyle(cornerRadius: 16)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("change_password_button")
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button {
            viewModel.requestLogout()
        } label: {
            HStack(spacing: 10) {
                if viewModel.isLoggingOut {
                    ProgressView()
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }

                Text("Çıxış et")
                    .font(.manropeSemiBold(17))
            }
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .cardStyle(cornerRadius: 16)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoggingOut)
        .accessibilityIdentifier("logout_button")
    }
}
