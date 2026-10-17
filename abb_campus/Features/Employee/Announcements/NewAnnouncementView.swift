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

                Section {
                    TextEditor(text: $viewModel.message)
                        .frame(minHeight: 140)
                        .accessibilityIdentifier("announcement_message")
                        .onChange(of: viewModel.message) {
                            viewModel.enforceMessageLimit()
                        }
                } header: {
                    Text("Məzmun")
                } footer: {
                    Text(viewModel.messageCounter)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }

                Section("Kimə") {
                    Picker("Auditoriya", selection: $viewModel.target) {
                        ForEach(AnnouncementTarget.allCases) { target in
                            Label(target.title, systemImage: target.icon)
                                .tag(target)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .accessibilityIdentifier("announcement_target")
                }

                Section("Vaciblik dərəcəsi") {
                    Picker("Vaciblik", selection: $viewModel.priority) {
                        ForEach(AnnouncementPriority.allCases) { priority in
                            Label {
                                Text(priority.title)
                            } icon: {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .accessibilityIdentifier("announcement_priority")
                }
            }
            .errorAlert(viewModel.errorMessage, onDismiss: viewModel.dismissError)
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
        }
    }
}
