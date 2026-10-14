import SwiftUI

struct ComingSoonView: View {

    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ContentUnavailableView {
            Label("Salam, \(viewModel.fullName)!", systemImage: "hammer.fill")
        } description: {
            Text("\(viewModel.roleTitle) bölməsi hazırlanır.")
        } actions: {
            Button {
                Task {
                    await viewModel.logout()
                }
            } label: {
                if viewModel.isLoggingOut {
                    ProgressView()
                } else {
                    Text("Çıxış et")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.isLoggingOut)
        }
        .font(.manropeRegular(16))
    }
}
