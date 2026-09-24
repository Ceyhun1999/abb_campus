import SwiftUI

struct AuthenticationView: View {

    @Environment(AuthenticationState.self) private var authenticationState

    var body: some View {
        RoleSelectionView(authenticationState: authenticationState)
    }
}

struct RoleSelectionView: View {
    @State private var viewModel: RoleSelectionViewModel
    @State private var showLogin: Bool = false

    init(authenticationState: AuthenticationState) {
        _viewModel = State(
            initialValue: RoleSelectionViewModel(
                authenticationState: authenticationState
            )
        )
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            backgroundDecoration

            VStack(spacing: 0) {
                headerView

                roleCardsView

                Spacer()

                footerView
            }
        }
        .navigationDestination(isPresented: $showLogin) {
            LoginView()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 0) {
            AppLogoView()
                .padding(.top, 40)

            Text("Xoş gəlmisiniz")
                .font(.custom("Manrope-Bold", size: 42))
                .tracking(-0.8)
                .padding(.top, 32)

            Text("Rolu seçin")
                .font(.custom("Manrope-Bold", size: 25))
                .padding(.top, 20)

            Text("Davam etmək üçün hesab növünüzü seçin")
                .font(.custom("Manrope-Regular", size: 16))
                .foregroundStyle(.secondary)
                .padding(.top, 6)
        }
    }

    // MARK: - Role Cards

    private var roleCardsView: some View {
        VStack(spacing: 16) {
            ForEach(UserRole.allCases) { role in
                Button {
                    viewModel.selectRole(role)
                    showLogin = true
                } label: {
                    RoleCardView(
                        icon: role.icon,
                        title: role.title,
                        subtitle: role.subtitle
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 18))

            Text("Hesablar əvvəlcədən yaradılır")
                .font(.custom("Manrope-Regular", size: 15))
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 55)
    }

    // MARK: - Background

    private var backgroundDecoration: some View {
        GeometryReader { geometry in
            ZStack {
                topLeftDecoration(geometry: geometry)
                bottomRightDecoration(geometry: geometry)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func topLeftDecoration(
        geometry: GeometryProxy
    ) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.07))
                .frame(width: 330, height: 330)
                .offset(
                    x: -geometry.size.width * 0.55,
                    y: -geometry.size.height * 0.22
                )

            Circle()
                .fill(Color.blue.opacity(0.035))
                .frame(width: 420, height: 420)
                .offset(
                    x: -geometry.size.width * 0.62,
                    y: -geometry.size.height * 0.27
                )
        }
    }

    private func bottomRightDecoration(
        geometry: GeometryProxy
    ) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.055))
                .frame(width: 390, height: 390)
                .offset(
                    x: geometry.size.width * 0.67,
                    y: geometry.size.height * 0.53
                )

            Circle()
                .fill(Color.blue.opacity(0.03))
                .frame(width: 470, height: 470)
                .offset(
                    x: geometry.size.width * 0.73,
                    y: geometry.size.height * 0.57
                )
        }
    }
}
 
