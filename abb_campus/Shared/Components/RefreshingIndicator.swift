import SwiftUI

extension View {

    func refreshingIndicator(_ isRefreshing: Bool) -> some View {
        overlay(alignment: .top) {
            if isRefreshing {
                ProgressView()
                    .padding(10)
                    .background(.regularMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                    .padding(.top, 8)
                    .transition(.opacity)
                    .accessibilityIdentifier("list_refreshing")
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isRefreshing)
    }
}
