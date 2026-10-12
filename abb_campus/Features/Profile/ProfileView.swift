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

                    logoutButton
                }
                .padding(.horizontal, AppLayout.horizontalPadding)
                .padding(.vertical, 20)
            }
            .background(.appBackground)
            .navigationTitle("Profil")
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
        VStack(spacing: 0) {
            ProfileInfoRow(
                icon: "envelope",
                title: "E-poçt",
                value: viewModel.email
            )

            Divider()
                .padding(.leading, 56)

            ProfileInfoRow(
                icon: "person.text.rectangle",
                title: "Rol",
                value: viewModel.roleTitle
            )
        }
        .cardStyle()
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

private struct ProfileInfoRow: View {

    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.blue)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.manropeRegular(13))
                    .foregroundStyle(.textSecondary)

                Text(value)
                    .font(.manropeSemiBold(16))
                    .foregroundStyle(.textPrimary)
            }

            Spacer()
        }
        .padding(16)
    }
}
