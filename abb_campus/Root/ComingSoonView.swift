import SwiftUI

/// Shown for roles whose screens are not implemented yet.
struct ComingSoonView: View {

    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 20) {
            IconCircleView(
                systemName: "hammer.fill",
                diameter: 110,
                iconSize: 44
            )

            Text("Salam, \(viewModel.fullName)!")
                .font(.manropeBold(24))
                .multilineTextAlignment(.center)

            Text("\(viewModel.roleTitle) bölməsi hazırlanır.")
                .font(.manropeRegular(16))
                .foregroundStyle(.secondary)

            PrimaryButton(
                title: "Çıxış et",
                isLoading: viewModel.isLoggingOut
            ) {
                Task {
                    await viewModel.logout()
                }
            }
            .padding(.top, 12)
        }
        .padding(.horizontal, AppLayout.horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
    }
}
