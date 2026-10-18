import SwiftUI

struct RoleSelectionView: View {

    @State private var viewModel: RoleSelectionViewModel

    init(viewModel: RoleSelectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            Color.screenBackground
                .ignoresSafeArea()

            BackgroundDecorView(style: .welcome)

            ScrollView {
                VStack(spacing: 0) {
                    headerView

                    roleCardsView
                }
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)
            .safeAreaInset(edge: .bottom) {
                footerView
            }
        }
        .navigationDestination(isPresented: $viewModel.isLoginPresented) {
            LoginView()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            AppLogoView()
                .padding(.top, 40)

            Text("Xoş gəlmisiniz")
                .font(.manropeBold(42))
                .tracking(-0.8)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .padding(.top, 32)

            Text("Rolu seçin")
                .font(.manropeBold(25))
                .padding(.top, 20)

            Text("Davam etmək üçün hesab növünüzü seçin")
                .font(.manropeRegular(16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
    }

    // MARK: - Role Cards

    private var roleCardsView: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.roles) { role in
                Button {
                    viewModel.selectRole(role)
                } label: {
                    RoleCardView(
                        icon: role.icon,
                        title: role.title,
                        subtitle: role.subtitle
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("role_\(role.rawValue)")
            }
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
        .padding(.top, 30)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 18))

            Text("Hesablar əvvəlcədən yaradılır")
                .font(.manropeRegular(15))
        }
        .foregroundStyle(.secondary)
        .padding(.vertical, 16)
    }
}

#Preview {
    let dependencies = AppDependencies.live
    let authenticationState = dependencies.makeAuthenticationState()

    NavigationStack {
        RoleSelectionView(
            viewModel: RoleSelectionViewModel(
                authenticationState: authenticationState
            )
        )
    }
    .environment(authenticationState)
}
