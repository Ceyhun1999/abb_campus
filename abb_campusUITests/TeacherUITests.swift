import XCTest

@MainActor
final class TeacherUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = .launchedForUITesting()

        XCTAssertTrue(app.openLogin(role: "teacher"))
        app.fillCredentials(email: "teacher@abb.local", password: "Password123!")
        app.buttons["login_button"].tap()
        XCTAssertTrue(app.staticTexts["teacher_greeting"].waitForExistence(timeout: uiTimeout))
    }

    func testTeacherCancelsALessonWithAReason() {
        XCTAssertTrue(app.descendants(matching: .any)["teacher_next_lessons"].waitForExistence(timeout: uiTimeout))

        let list = app.descendants(matching: .any)["teacher_schedule_list"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Cədvəl"], until: list))

        let lesson = app.staticTexts["SwiftUI layout"]
        XCTAssertTrue(lesson.waitForExistence(timeout: uiTimeout))
        lesson.press(forDuration: 1.0)

        let cancel = app.buttons["Ləğv et"]
        XCTAssertTrue(cancel.waitForExistence(timeout: uiTimeout))
        cancel.tap()

        XCTAssertTrue(app.buttons["Bayram"].waitForExistence(timeout: uiTimeout))
        app.buttons["Bayram"].tap()
        app.buttons["cancel_lesson_submit"].tap()

        XCTAssertTrue(app.staticTexts["Ləğv edildi"].waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(app.descendants(matching: .any)["lesson_cancel_reason"].exists)
    }

    func testTeacherSchedulesAnExamAndOpensMonthlyUploads() {
        let group = app.buttons["teacher_group_row_1"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Qruplar"], until: group))
        XCTAssertTrue(app.tap(group, until: app.buttons["teacher_route_3"]))

        XCTAssertTrue(app.tap(app.buttons["teacher_route_3"], until: app.buttons["schedule_exam_button"]))
        XCTAssertTrue(app.buttons["upload_exam_scores_103"].exists)

        XCTAssertTrue(app.tap(app.buttons["schedule_exam_button"], until: app.textFields["exam_title_field"]))
        app.textFields["exam_title_field"].type("Final imtahanı")
        app.buttons["exam_save_button"].tap()
        XCTAssertTrue(app.staticTexts["Final imtahanı"].waitForExistence(timeout: uiTimeout))

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.tap(app.buttons["teacher_route_1"], until: app.buttons["import_attendance_button"]))
        XCTAssertTrue(app.staticTexts["Nihad Məmmədov"].exists)

        XCTAssertTrue(app.tap(app.buttons["import_attendance_button"], until: app.buttons["pick_file_button"]))
        XCTAssertTrue(app.navigationBars["Davamiyyət importu"].exists)
    }
}
