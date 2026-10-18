import XCTest

@MainActor
final class EmployeeUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = .launchedForUITesting()
    }

    func testEmployeeDeletesAStudent() {
        signInAsEmployee()

        XCTAssertTrue(app.descendants(matching: .any)["academy_card"].waitForExistence(timeout: uiTimeout))

        let student = app.buttons["student_row_13"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Tələbələr"], until: student))
        XCTAssertFalse(app.segmentedControls["student_status_filter"].exists, "no status filter any more")

        let name = app.staticTexts["student_detail_name"]
        XCTAssertTrue(app.tap(student, until: name))
        XCTAssertEqual(name.label, "Rəşad İsmayılov")

        let confirm = app.buttons["confirm_delete_student"].firstMatch
        XCTAssertTrue(app.tap(app.buttons["delete_student_button"], until: confirm))
        confirm.tap()

        XCTAssertTrue(app.buttons["student_row_11"].waitForExistence(timeout: uiTimeout), "back on the list")
        XCTAssertTrue(student.waitForDisappearance(), "the deleted student is gone")
    }

    func testEmployeeOpensGroupAndImportScreen() {
        signInAsEmployee()

        let groupRow = app.buttons["group_row_1"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Qruplar"], until: groupRow))

        let importButton = app.buttons["import_students_button"]
        XCTAssertTrue(app.tap(groupRow, until: importButton))

        let pickFile = app.buttons["pick_file_button"]
        XCTAssertTrue(app.tap(importButton, until: pickFile))
        XCTAssertFalse(app.buttons["import_submit"].isEnabled)
    }

    func testEmployeeOpensGroupScheduleAndScheduleImport() {
        signInAsEmployee()

        let groupRow = app.buttons["group_row_1"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Qruplar"], until: groupRow))

        let scheduleButton = app.buttons["group_schedule_button"]
        XCTAssertTrue(app.tap(groupRow, until: scheduleButton))
        if !scheduleButton.isHittable {
            app.swipeUp()
        }

        let importButton = app.buttons["import_schedule_button"]
        XCTAssertTrue(app.tap(scheduleButton, until: importButton))
        XCTAssertTrue(app.staticTexts["Qrupun cədvəli hələ yoxdur. Excel faylından idxal edin."].waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(importButton.isEnabled)

        let pickFile = app.buttons["pick_file_button"]
        XCTAssertTrue(app.tap(importButton, until: pickFile))
        XCTAssertTrue(app.navigationBars["Cədvəl importu"].exists)
        XCTAssertFalse(app.buttons["import_submit"].isEnabled)
    }

    func testTeachersTabAndAllAnnouncementsFromHome() {
        signInAsEmployee()

        XCTAssertTrue(app.tap(app.buttons["all_announcements_button"], until: app.buttons["new_announcement_button"]))

        XCTAssertTrue(app.tap(app.tabBars.buttons["Müəllimlər"], until: app.navigationBars["Müəllimlər"]))
        XCTAssertTrue(app.segmentedControls["teacher_position_filter"].exists)
    }

    private func signInAsEmployee() {
        XCTAssertTrue(app.openLogin(role: "employee"))

        app.fillCredentials(email: "employee@abb.local", password: "Password123!")
        app.buttons["login_button"].tap()

        XCTAssertTrue(app.staticTexts["employee_greeting"].waitForExistence(timeout: uiTimeout))
    }
}
