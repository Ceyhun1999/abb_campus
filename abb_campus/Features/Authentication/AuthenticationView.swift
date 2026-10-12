import SwiftUI

struct AuthenticationView: View {

    @Environment(AuthenticationState.self) private var authenticationState

    var body: some View {
        RoleSelectionView(
            viewModel: RoleSelectionViewModel(
                authenticationState: authenticationState
            )
        )
    }
}
