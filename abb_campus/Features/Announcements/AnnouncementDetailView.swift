import SwiftUI

struct AnnouncementDetailView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: AnnouncementDetailViewModel

    init(viewModel: AnnouncementDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var announcement: Announcement {
        viewModel.announcement
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AnnouncementRow(announcement: announcement)
                    .padding(16)
                    .cardStyle()

                PriorityBadge(priority: announcement.priority)

                Text(announcement.message)
                    .font(.manropeRegular(16))
                    .foregroundStyle(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .cardStyle()

                if !announcement.linkURLs.isEmpty {
                    linksCard
                }
            }
            .padding(.horizontal, AppLayout.horizontalPadding)
            .padding(.vertical, 20)
        }
        .background(.appBackground)
        .navigationTitle("Elan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.canManage {
                ToolbarItem(placement: .primaryAction) {
                    if viewModel.isDeleting {
                        ProgressView()
                    } else {
                        Menu {
                            Button {
                                viewModel.showEdit()
                            } label: {
                                Label("Redaktə et", systemImage: "pencil")
                            }
                            .accessibilityIdentifier("edit_announcement_button")

                            Button(role: .destructive) {
                                viewModel.requestDelete()
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                            .accessibilityIdentifier("delete_announcement_button")
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .accessibilityLabel("Elan əməliyyatları")
                        .accessibilityIdentifier("announcement_actions")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isEditPresented) {
            if let editViewModel = viewModel.editViewModel {
                AnnouncementFormView(viewModel: editViewModel) { updated in
                    viewModel.saved(updated)
                }
            }
        }
        .confirmationDialog(
            "Elan silinsin? Bu əməliyyatı geri qaytarmaq olmaz.",
            isPresented: $viewModel.isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Sil", role: .destructive) {
                Task {
                    await viewModel.delete()
                }
            }
            .accessibilityIdentifier("confirm_delete_announcement")

            Button("Ləğv et", role: .cancel) {}
        }
        .errorAlert(viewModel.errorMessage, onDismiss: viewModel.dismissError)
        .onChange(of: viewModel.isDeleted) { _, isDeleted in
            if isDeleted {
                dismiss()
            }
        }
    }

    // MARK: - Links

    private var linksCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(announcement.linkURLs, id: \.self) { url in
                Link(destination: url) {
                    HStack(spacing: 12) {
                        Image(systemName: "link")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.blue)
                            .frame(width: 26)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(url.host() ?? url.absoluteString)
                                .font(.manropeSemiBold(15))
                                .foregroundStyle(.textPrimary)

                            Text(url.absoluteString)
                                .font(.manropeRegular(12))
                                .foregroundStyle(.textSecondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.textSecondary)
                    }
                    .padding(16)
                }
                .accessibilityIdentifier("announcement_link")

                if url != announcement.linkURLs.last {
                    InfoDivider()
                }
            }
        }
        .cardStyle()
    }
}
