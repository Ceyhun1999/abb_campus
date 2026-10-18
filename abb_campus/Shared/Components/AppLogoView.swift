import SwiftUI

struct AppLogoView: View {

    var height: CGFloat = 72

    var body: some View {
        Image("logo")
            .resizable()
            .scaledToFit()
            .frame(height: height)
    }
}

#Preview {
    AppLogoView()
}
