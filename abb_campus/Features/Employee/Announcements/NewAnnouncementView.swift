import SwiftUI

struct NewAnnouncementView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: NewAnnouncementViewModel

    let onPublished: () -> Void

    init(viewModel: NewAnnouncementViewModel, onPublished: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onPublished = onPublished
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            Form {
                Section("Başlıq") {
                    TextField("Elanın başlığını daxil edin", text: $viewModel.title)
                        .accessibilityIdentifier("announcement_title")
                }

                Section("Hədəf auditoriya") {
                    Picker("Auditoriya", selection: $viewModel.target) {
                        ForEach(AnnouncementTarget.allCases) { target in
                            Text(target.title).tag(target)
                        }
                    }

                    if viewModel.target == .group {
                        groupPicker
                    }
                }

                Section {
                    TextEditor(text: $viewModel.message)
                        .frame(minHeight: 140)
                        .accessibilityIdentifier("announcement_message")
                } header: {
                    Text("Məzmun")
                } footer: {
                    Text(viewModel.messageCounter)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        ErrorMessageText(message: errorMessage, accessibilityID: "announcement_error")
                    }
                }
            }
            .navigationTitle("Yeni elan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ləğv et") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSending {
                        ProgressView()
                    } else {
                        Button("Dərc et") {
                            Task {
                                if await viewModel.publish() != nil {
                                    onPublished()
                                }
                            }
                        }
                        .accessibilityIdentifier("announcement_publish")
                    }
                }
            }
            .task(id: viewModel.target) {
                if viewModel.target == .group {
                    await viewModel.loadGroups()
                }
            }
        }
    }

    @ViewBuilder
    private var groupPicker: some View {
        @Bindable var viewModel = viewModel

        switch viewModel.groups {
        case .loaded(let groups):
            Picker("Qrup", selection: $viewModel.selectedGroupId) {
                Text("Seçin").tag(Int?.none)

                ForEach(groups) { group in
                    Text(group.name).tag(Optional(group.id))
                }
            }

        case .failed(let message):
            Text(message)
                .foregroundStyle(.red)

        case .idle, .loading:
            ProgressView()
        }
    }
}
