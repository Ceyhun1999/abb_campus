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

            // Fits the screen without scrolling; it scrolls only when the content cannot fit,
            // for example with a very large text size.
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        headerView

                        roleCardsView

                        Spacer(minLength: 16)

                        footerView
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .navigationDestination(isPresented: $viewModel.isLoginPresented) {
            LoginView()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            AppLogoView(height: 64)
                .padding(.top, 24)

            Text("Xoş gəlmisiniz")
                .font(.manropeBold(40))
                .tracking(-0.8)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .padding(.top, 20)

            Text("Rolu seçin")
                .font(.manropeBold(24))
                .padding(.top, 12)

            Text("Davam etmək üçün hesab növünüzü seçin")
                .font(.manropeRegular(16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
    }

    // MARK: - Role Cards

    private var roleCardsView: some View {
        VStack(spacing: 12) {
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
        .padding(.top, 24)
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
