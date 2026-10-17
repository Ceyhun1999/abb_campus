import Foundation
import Testing
@testable import abb_campus

@Suite("Networking")
struct EmployeeEndpointTests {

    // MARK: - Students

    @Test("Students request has search and status query items")
    func studentsRequest() throws {
        let request = try EmployeeEndpoint.students(search: "Nihad", status: .active, courseId: 4, page: 1).makeRequest()
        let components = try #require(request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) })

        #expect(components.path == "/api/students")
        #expect(components.queryItems?.contains(URLQueryItem(name: "search", value: "Nihad")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "status", value: "active")) == true)
        #expect(request.httpMethod == "GET")
    }

    @Test("Empty search and 'all' filter are not sent")
    func studentsRequestWithoutFilters() throws {
        let request = try EmployeeEndpoint.students(search: "", status: .all, courseId: nil, page: 1).makeRequest()
        let query = request.url?.query ?? ""

        #expect(!query.contains("search"))
        #expect(!query.contains("status"))
    }

    @Test("Status change is a PATCH with a JSON body")
    func statusRequest() throws {
        let request = try EmployeeEndpoint.setUserStatus(userId: 5, isActive: false).makeRequest()
        let body = try #require(request.httpBody)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Bool]

        #expect(request.httpMethod == "PATCH")
        #expect(request.url?.path == "/api/users/5/status")
        #expect(json == ["isActive": false])
    }

    // MARK: - Import

    @Test("Import uses multipart form data")
    func importRequest() throws {
        var form = MultipartFormData()
        form.addFile(name: "file", fileName: "a.csv", mimeType: "text/csv", data: Data("x".utf8))

        let request = try EmployeeEndpoint.importStudents(groupId: 3, form: form).makeRequest()
        let body = String(decoding: try #require(request.httpBody), as: UTF8.self)

        #expect(request.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data; boundary=") == true)
        #expect(body.contains("filename=\"a.csv\""))
        #expect(body.hasSuffix("--\r\n"))
    }

    @Test("Group schedule loads every lesson in one request")
    func groupScheduleRequest() throws {
        let request = try EmployeeEndpoint.groupSchedule(groupId: 3).makeRequest()

        #expect(request.httpMethod == "GET")
        #expect(request.url?.path == "/api/groups/3/schedule")
        #expect(request.url?.query == "perPage=2000")
    }

    @Test("Schedule import is a multipart POST to the group's schedule")
    func importScheduleRequest() throws {
        var form = MultipartFormData()
        form.addFile(name: "file", fileName: "cedvel.xlsx", mimeType: "application/octet-stream", data: Data("x".utf8))

        let request = try EmployeeEndpoint.importSchedule(groupId: 3, form: form).makeRequest()
        let body = String(decoding: try #require(request.httpBody), as: UTF8.self)

        #expect(request.httpMethod == "POST")
        #expect(request.url?.path == "/api/groups/3/schedule/import")
        #expect(request.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data; boundary=") == true)
        #expect(body.contains("filename=\"cedvel.xlsx\""))
    }

    // MARK: - Auth

    @Test("Change password is an authorized POST with snake_case keys")
    func changePasswordRequest() throws {
        let body = ChangePasswordRequest(currentPassword: "old", password: "NewPass456!", passwordConfirmation: "NewPass456!")
        let request = try AuthEndpoint.changePassword(token: "abc", body).makeRequest()
        let data = try #require(request.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: String])

        #expect(request.httpMethod == "POST")
        #expect(request.url?.path == "/api/auth/change-password")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer abc")
        #expect(json["current_password"] == "old")
        #expect(json["password_confirmation"] == "NewPass456!")
    }

    // MARK: - Teachers

    @Test("A new announcement sends priority and audience, no group")
    func createAnnouncementBody() throws {
        let body = AnnouncementFormRequest(
            title: "İclas", message: "18:00", target: .teachers, priority: .high, links: ["https://abbtech.az"]
        )
        let request = try EmployeeEndpoint.createAnnouncement(body).makeRequest()
        let data = try #require(request.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(json["target"] as? String == "teachers")
        #expect(json["priority"] as? String == "high")
        #expect(json["links"] as? [String] == ["https://abbtech.az"])
        #expect(json["groupId"] == nil)
    }

    @Test("Editing is a PATCH and deleting a DELETE on the announcement")
    func editAndDeleteAnnouncementRequests() throws {
        let body = AnnouncementFormRequest(title: "A", message: "B", target: .everyone, priority: .low)
        let update = try EmployeeEndpoint.updateAnnouncement(id: 7, body).makeRequest()
        let delete = try EmployeeEndpoint.deleteAnnouncement(id: 7).makeRequest()

        #expect(update.httpMethod == "PATCH")
        #expect(update.url?.path == "/api/announcements/7")
        #expect(delete.httpMethod == "DELETE")
        #expect(delete.url?.path == "/api/announcements/7")
        #expect(delete.httpBody == nil)
    }

    @Test("Announcements decode their priority")
    func decodeAnnouncement() throws {
        let json = #"{"id": 1, "title": "İclas", "message": "18:00", "target": "teachers", "priority": "high", "createdAt": null}"#
        let announcement = try JSONDecoder().decode(Announcement.self, from: Data(json.utf8))

        #expect(announcement.priority == .high)
        #expect(announcement.audienceTitle == "Müəllim və mentorlar")
        #expect(announcement.links.isEmpty)

        let withLinks = #"{"id": 2, "title": "Mənbələr", "message": "x", "links": ["https://abbtech.az"], "target": "students", "priority": "low", "createdAt": null}"#
        let decoded = try JSONDecoder().decode(Announcement.self, from: Data(withLinks.utf8))

        #expect(decoded.linkURLs == [URL(string: "https://abbtech.az")])
    }

    @Test("Lists ask for 20 rows of the given page, pickers for everything")
    func pagingQuery() throws {
        let list = try EmployeeEndpoint.teachers(search: "", position: .all, specialty: nil, page: 3).makeRequest()
        let picker = try EmployeeEndpoint.teachers(search: "", position: .all, specialty: nil, page: nil).makeRequest()
        let listItems = URLComponents(url: try #require(list.url), resolvingAgainstBaseURL: false)?.queryItems ?? []
        let pickerItems = URLComponents(url: try #require(picker.url), resolvingAgainstBaseURL: false)?.queryItems ?? []

        #expect(listItems.contains(URLQueryItem(name: "page", value: "3")))
        #expect(listItems.contains(URLQueryItem(name: "perPage", value: "20")))
        #expect(pickerItems.contains(URLQueryItem(name: "perPage", value: "200")))
        #expect(!pickerItems.contains { $0.name == "page" })
    }

    @Test("Teacher filters are sent as query parameters")
    func teacherFilterQuery() throws {
        let request = try EmployeeEndpoint.teachers(search: "", position: .mentor, specialty: "UI/UX Design", page: nil).makeRequest()
        let items = URLComponents(url: try #require(request.url), resolvingAgainstBaseURL: false)?.queryItems ?? []

        #expect(items.contains(URLQueryItem(name: "position", value: "mentor")))
        #expect(items.contains(URLQueryItem(name: "specialty", value: "UI/UX Design")))
        #expect(!items.contains { $0.name == "search" })
    }

    // MARK: - Groups

    @Test("Group course filter is sent as courseId")
    func groupCourseQuery() throws {
        let request = try EmployeeEndpoint.groups(search: "", courseId: 4, page: nil).makeRequest()
        let items = URLComponents(url: try #require(request.url), resolvingAgainstBaseURL: false)?.queryItems ?? []

        #expect(items.contains(URLQueryItem(name: "courseId", value: "4")))
    }

    @Test("Editing a group is a PATCH that sends an empty teacher as null")
    func updateGroupRequest() throws {
        let form = GroupFormRequest(name: "IOS-05", courseId: 1, teacherId: nil, mentorIds: [3, 4],
                                    startDate: "2026-09-01", endDate: "2027-03-01", isActive: false)
        let request = try EmployeeEndpoint.updateGroup(id: 5, form).makeRequest()
        let body = try #require(request.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])

        #expect(request.httpMethod == "PATCH")
        #expect(request.url?.path == "/api/groups/5")
        #expect(json["teacherId"] is NSNull)
        #expect(json["mentorIds"] as? [Int] == [3, 4])
    }

    // MARK: - Authorization

    @Test("All employee endpoints require authorization")
    func requiresAuthorization() {
        #expect(EmployeeEndpoint.dashboard.requiresAuthorization)
        #expect(AuthEndpoint.login(LoginRequest(email: "", password: "", role: .student)).requiresAuthorization == false)
    }
}
