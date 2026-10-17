import Foundation
import Observation

@MainActor
@Observable
final class AnnouncementsListViewModel {

    var isCreatePresented = false
    private let list = PagedList<Announcement>()
    private(set) var newAnnouncementViewModel: NewAnnouncementViewModel?

    private let announcementService: any AnnouncementService
    private let groupService: any GroupService

    init(announcementService: any AnnouncementService, groupService: any GroupService) {
        self.announcementService = announcementService
        self.groupService = groupService
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
        newAnnouncementViewModel = NewAnnouncementViewModel(
            announcementService: announcementService,
            groupService: groupService
        )
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
    var message = "" {
        didSet {
            if message.count > Self.maxMessageLength {
                message = String(message.prefix(Self.maxMessageLength))
            }
        }
    }
    var target: AnnouncementTarget = .students
    var selectedGroupId: Int?

    private(set) var groups: ViewState<[StudyGroup]> = .idle
    private(set) var isSending = false
    private(set) var errorMessage: String?

    private let announcementService: any AnnouncementService
    private let groupService: any GroupService

    init(
        announcementService: any AnnouncementService,
        groupService: any GroupService
    ) {
        self.announcementService = announcementService
        self.groupService = groupService
    }

    func dismissError() {
        errorMessage = nil
    }

    var messageCounter: String {
        "\(message.count)/\(Self.maxMessageLength)"
    }

    func loadGroups() async {
        guard groups.value == nil else {
            return
        }

        groups = .loading

        do {
            groups = .loaded(try await groupService.fetchGroups(search: "", courseId: nil))
        } catch {
            groups = .failed(error.localizedDescription)
        }
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

        guard target != .group || selectedGroupId != nil else {
            errorMessage = ValidationMessage.groupNotSelected
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
                    groupId: target == .group ? selectedGroupId : nil
                )
            )
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
