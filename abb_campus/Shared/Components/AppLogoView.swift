import SwiftUI

struct AppLogoView:View {
    
    var body: some View {
        Image("logo")
            .resizable()
            .scaledToFit()
            .frame(height: 72)
    }
}

#Preview {
    AppLogoView()
}
