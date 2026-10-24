import Foundation
import Testing
@testable import abb_campus

@Suite("Teacher and lesson requests")
struct TeachingEndpointTests {

    @Test("Monthly results are requested with the month")
    func monthlyRequests() throws {
        let attendance = try TeachingEndpoint.attendanceSummary(groupId: 3, month: "2026-10").makeRequest()
        let scores = try TeachingEndpoint.assessments(groupId: 3, month: "2026-10").makeRequest()

        #expect(attendance.url?.path == "/api/groups/3/attendance/summary")
        #expect(attendance.url?.query == "month=2026-10")
        #expect(scores.url?.path == "/api/groups/3/assessments")
    }

    @Test("Teachers read their notifications from the shared feed")
    func announcements() throws {
        let request = try TeachingEndpoint.announcements.makeRequest()

        #expect(request.httpMethod == "GET")
        #expect(request.url?.path == "/api/my/announcements")
        #expect(request.url?.query == "perPage=200")
    }

    @Test("Task scores upload sends the month as a form field")
    func taskScoresUpload() throws {
        let form = MultipartFormData.spreadsheet(fileName: "ballar.xlsx", data: Data("x".utf8), fields: ["month": "2026-10"])
        let request = try TeachingEndpoint.importTaskScores(groupId: 3, form: form).makeRequest()
        let body = String(decoding: try #require(request.httpBody), as: UTF8.self)

        #expect(request.httpMethod == "POST")
        #expect(request.url?.path == "/api/groups/3/tasks/import")
        #expect(body.contains("name=\"month\"\r\n\r\n2026-10"))
        #expect(body.contains("filename=\"ballar.xlsx\""))
        #expect(body.contains("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
    }

    @Test("Exam is scheduled with camelCase JSON")
    func scheduleExam() throws {
        let exam = ExamFormRequest(title: "Final", date: "2026-11-02", startsAt: "09:30", endsAt: "11:00", room: nil)
        let request = try TeachingEndpoint.scheduleExam(groupId: 3, exam).makeRequest()
        let json = try JSONSerialization.jsonObject(with: try #require(request.httpBody)) as? [String: Any]

        #expect(request.httpMethod == "POST")
        #expect(request.url?.path == "/api/groups/3/exams")
        #expect(json?["startsAt"] as? String == "09:30")
        #expect(json?["date"] as? String == "2026-11-02")
    }

    @Test("Cancelling sends the reason code and note")
    func cancelLesson() throws {
        let request = try LessonEndpoint.cancel(lessonId: 8, CancelLessonRequest(reason: .teacherSick, note: nil)).makeRequest()
        let json = try JSONSerialization.jsonObject(with: try #require(request.httpBody)) as? [String: Any]

        #expect(request.httpMethod == "POST")
        #expect(request.url?.path == "/api/lessons/8/cancel")
        #expect(json?["reason"] as? String == "teacher_sick")
    }

    @Test("Exam scores go to the exam")
    func examScoresUpload() throws {
        let request = try TeachingEndpoint.importExamScores(examId: 12, form: .spreadsheet(fileName: "final.csv", data: Data())).makeRequest()

        #expect(request.url?.path == "/api/exams/12/scores/import")
        #expect(request.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data") == true)
    }
}
