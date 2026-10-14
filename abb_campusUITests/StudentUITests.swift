import XCTest

@MainActor
final class StudentUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = .launchedForUITesting()
    }

    func testStudentSeesDashboardAttendanceAndModuleGrades() {
        XCTAssertTrue(app.openLogin(role: "student"))
        app.fillCredentials(email: "student@abb.local", password: "Password123!")
        app.buttons["login_button"].tap()

        let nextLesson = app.staticTexts["next_lesson_title"]
        XCTAssertTrue(nextLesson.waitForExistence(timeout: uiTimeout))
        XCTAssertEqual(nextLesson.label, "SwiftUI layout")

        let attendanceSummary = app.staticTexts["attendance_summary"]
        XCTAssertTrue(app.tap(app.buttons["attendance_card"], until: attendanceSummary))
        XCTAssertEqual(attendanceSummary.label, "2 / 2 dərs")

        let moduleRow = app.buttons["module_row_1"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Qiymətlər"], until: moduleRow))

        let totalScore = app.staticTexts["module_total_score"]
        XCTAssertTrue(app.tap(moduleRow, until: totalScore))
        XCTAssertTrue(totalScore.label.hasSuffix("64 / 75"), totalScore.label)
    }
}
