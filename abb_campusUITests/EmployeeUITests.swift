import XCTest

@MainActor
final class EmployeeUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = .launchedForUITesting()
    }

    func testEmployeeSeesDashboardAndFiltersStudents() {
        signInAsEmployee()

        let total = app.staticTexts["total_students_count"]
        XCTAssertTrue(total.waitForExistence(timeout: uiTimeout))
        XCTAssertEqual(total.label, "3")

        let activeStudent = app.buttons["student_row_11"]
        let inactiveStudent = app.buttons["student_row_13"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Tələbələr"], until: activeStudent))
        XCTAssertTrue(inactiveStudent.exists)

        app.segmentedControls.buttons["Deaktiv"].tap()
        XCTAssertTrue(activeStudent.waitForDisappearance())
        XCTAssertTrue(inactiveStudent.exists)

        let name = app.staticTexts["student_detail_name"]
        XCTAssertTrue(app.tap(inactiveStudent, until: name))
        XCTAssertEqual(name.label, "Rəşad İsmayılov")
        XCTAssertTrue(app.buttons["student_status_button"].exists)
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

    func testHomeTilesOpenTheirTabs() {
        signInAsEmployee()

        let activeStudent = app.buttons["student_row_11"]
        XCTAssertTrue(app.tap(app.buttons["active_students_tile"], until: activeStudent))
        XCTAssertFalse(app.buttons["student_row_13"].exists)

        XCTAssertTrue(app.tap(app.tabBars.buttons["Ana səhifə"], until: app.buttons["groups_tile"]))
        XCTAssertTrue(app.tap(app.buttons["groups_tile"], until: app.buttons["group_row_1"]))
    }

    private func signInAsEmployee() {
        XCTAssertTrue(app.openLogin(role: "employee"))

        app.fillCredentials(email: "employee@abb.local", password: "Password123!")
        app.buttons["login_button"].tap()

        XCTAssertTrue(app.staticTexts["employee_greeting"].waitForExistence(timeout: uiTimeout))
    }
}
