import SwiftUI

struct LoadMoreIndicator: View {

    let isLoading: Bool

    var body: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .accessibilityIdentifier("load_more_indicator")
        }
    }
}
