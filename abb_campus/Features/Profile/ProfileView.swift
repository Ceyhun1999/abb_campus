import SwiftUI

struct ProfileView: View {

    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            // Fits one screen on most iPhones; on a small one (iPhone SE) it scrolls,
            // so the buttons are never stuck under the tab bar.
            ScrollView {
                content
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

    private var content: some View {
        VStack(spacing: 14) {
            headerView

            infoCard

            appearanceCard

            changePasswordButton

            logoutButton
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
        .padding(.vertical, 8)
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 8) {
            Text(viewModel.initials)
                .font(.manropeBold(26))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
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

    // MARK: - Appearance

    private var appearanceCard: some View {
        @Bindable var viewModel = viewModel

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Image(systemName: viewModel.appearanceMode.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(.blue)
                    .frame(width: 26)

                Text("Görünüş")
                    .font(.manropeSemiBold(17))
                    .foregroundStyle(.textPrimary)
            }

            Picker("Görünüş", selection: $viewModel.appearanceMode) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("appearance_picker")
        }
        .padding(14)
        .cardStyle(cornerRadius: 16)
    }

    // MARK: - Password

    private var changePasswordButton: some View {
        Button {
            viewModel.showChangePassword()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "key")
                    .font(.system(size: 18))
                    .foregroundStyle(.blue)
                    .frame(width: 26)

                Text("Şifrəni dəyiş")
                    .font(.manropeSemiBold(17))
                    .foregroundStyle(.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
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
            HStack(spacing: 14) {
                Group {
                    if viewModel.isLoggingOut {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18))
                    }
                }
                .frame(width: 26)

                Text("Çıxış et")
                    .font(.manropeSemiBold(17))

                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(.red)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoggingOut)
        .accessibilityIdentifier("logout_button")
    }
}
