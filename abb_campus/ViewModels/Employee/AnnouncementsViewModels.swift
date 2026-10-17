import Foundation
import Observation

@MainActor
@Observable
final class AnnouncementsListViewModel {

    var isCreatePresented = false
    private let list = PagedList<Announcement>()
    private(set) var newAnnouncementViewModel: NewAnnouncementViewModel?

    private let announcementService: any AnnouncementService

    init(announcementService: any AnnouncementService) {
        self.announcementService = announcementService
    }

    // MARK: - Paging

    var state: ViewState<[Announcement]> {
        list.state
    }

    var isLoadingMore: Bool {
        list.isLoadingMore
    }

    func loadMoreIfNeeded(_ item: Announcement) async {
        await list.loadMore(after: item)
    }

    func load() async {
        let service = announcementService

        await list.load { page in
            try await service.fetchAnnouncements(page: page)
        }
    }

    func showCreate() {
        newAnnouncementViewModel = NewAnnouncementViewModel(announcementService: announcementService)
        isCreatePresented = true
    }

    func announcementCreated() async {
        isCreatePresented = false
        newAnnouncementViewModel = nil
        await load()
    }
}

@MainActor
@Observable
final class NewAnnouncementViewModel {

    static let maxMessageLength = 500

    var title = ""
    var message = ""
    var target: AnnouncementTarget = .everyone
    var priority: AnnouncementPriority = .medium
    var links: [LinkDraft] = []

    private(set) var isSending = false
    private(set) var errorMessage: String?

    private let announcementService: any AnnouncementService

    init(announcementService: any AnnouncementService) {
        self.announcementService = announcementService
    }

    func dismissError() {
        errorMessage = nil
    }

    func enforceMessageLimit() {
        if message.count > Self.maxMessageLength {
            message = String(message.prefix(Self.maxMessageLength))
        }
    }

    var messageCounter: String {
        "\(message.count)/\(Self.maxMessageLength)"
    }

    // MARK: - Links

    static let maxLinks = 3

    var canAddLink: Bool {
        links.count < Self.maxLinks
    }

    func addLink() {
        guard canAddLink else {
            return
        }

        links.append(LinkDraft())
    }

    func removeLink(_ link: LinkDraft) {
        links.removeAll { $0.id == link.id }
    }

    static func normalizedLinks(_ drafts: [LinkDraft]) -> [String]? {
        var result: [String] = []

        for draft in drafts {
            var text = draft.text.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !text.isEmpty else {
                continue
            }

            if !text.lowercased().hasPrefix("http://") && !text.lowercased().hasPrefix("https://") {
                text = "https://" + text
            }

            guard let url = URL(string: text),
                  let host = url.host(),
                  host.contains("."),
                  !host.hasPrefix("."),
                  !host.hasSuffix(".") else {
                return nil
            }

            if !result.contains(text) {
                result.append(text)
            }
        }

        return result
    }

    // MARK: - Publish

    func publish() async -> Announcement? {
        guard !isSending else {
            return nil
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            errorMessage = ValidationMessage.emptyAnnouncementTitle
            return nil
        }

        guard !trimmedMessage.isEmpty else {
            errorMessage = ValidationMessage.emptyAnnouncementMessage
            return nil
        }

        guard let normalizedLinks = Self.normalizedLinks(links) else {
            errorMessage = ValidationMessage.invalidLink
            return nil
        }

        errorMessage = nil
        isSending = true

        defer {
            isSending = false
        }

        do {
            return try await announcementService.createAnnouncement(
                CreateAnnouncementRequest(
                    title: trimmedTitle,
                    message: trimmedMessage,
                    target: target,
                    priority: priority,
                    links: normalizedLinks
                )
            )
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}

struct LinkDraft: Identifiable, Equatable {
    let id = UUID()
    var text = ""
}
