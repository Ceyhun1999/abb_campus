import SwiftUI

struct LaunchLoadingView: View {

    var body: some View {
        VStack(spacing: 24) {
            AppLogoView()

            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    LaunchLoadingView()
}
