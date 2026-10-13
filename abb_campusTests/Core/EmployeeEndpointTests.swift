import Foundation
import Testing
@testable import abb_campus

@Suite("Networking")
struct EmployeeEndpointTests {

    @Test("Students request has search and status query items")
    func studentsRequest() throws {
        let request = try EmployeeEndpoint.students(search: "Nihad", status: .active).makeRequest()
        let components = try #require(request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) })

        #expect(components.path == "/api/students")
        #expect(components.queryItems?.contains(URLQueryItem(name: "search", value: "Nihad")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "status", value: "active")) == true)
        #expect(request.httpMethod == "GET")
    }

    @Test("Empty search and 'all' filter are not sent")
    func studentsRequestWithoutFilters() throws {
        let request = try EmployeeEndpoint.students(search: "", status: .all).makeRequest()
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

    @Test("Editing a group is a PATCH that sends an empty teacher as null")
    func updateGroupRequest() throws {
        let form = GroupFormRequest(name: "IOS-05", courseId: 1, teacherId: nil, mentorIds: [3, 4],
                                    startDate: "2026-09-01", endDate: nil, isActive: false)
        let request = try EmployeeEndpoint.updateGroup(id: 5, form).makeRequest()
        let body = try #require(request.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])

        #expect(request.httpMethod == "PATCH")
        #expect(request.url?.path == "/api/groups/5")
        #expect(json["teacherId"] is NSNull)
        #expect(json["mentorIds"] as? [Int] == [3, 4])
    }

    @Test("All employee endpoints require authorization")
    func requiresAuthorization() {
        #expect(EmployeeEndpoint.dashboard.requiresAuthorization)
        #expect(AuthEndpoint.login(LoginRequest(email: "", password: "", role: .student)).requiresAuthorization == false)
    }
}
