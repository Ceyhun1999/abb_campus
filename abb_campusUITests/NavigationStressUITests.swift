import XCTest

@MainActor
final class NavigationStressUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = .launchedForUITesting()

        XCTAssertTrue(app.openLogin(role: "employee"))
        app.fillCredentials(email: "employee@abb.local", password: "Password123!")
        app.buttons["login_button"].tap()
        XCTAssertTrue(app.staticTexts["employee_greeting"].waitForExistence(timeout: uiTimeout))
    }

    func testRepeatedPushAndPopKeepsOneScreen() {
        let row = app.buttons["group_row_1"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Qruplar"], until: row))

        for index in 0..<20 {
            XCTAssertTrue(app.tap(row, until: app.buttons["edit_group_button"]), "push \(index)")

            if index.isMultiple(of: 2) {
                let back = app.navigationBars.buttons.firstMatch
                XCTAssertTrue(back.waitForExistence(timeout: uiTimeout), "back button \(index)")
                back.tap()
            } else {
                let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.01, dy: 0.5))
                start.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)))
            }

            XCTAssertTrue(row.waitForExistence(timeout: uiTimeout), "pop \(index)")
            XCTAssertEqual(app.navigationBars.count, 1, "one screen after pop \(index)")
            XCTAssertFalse(app.descendants(matching: .any)["loading_view"].exists, "no stuck loader after pop \(index)")
        }
    }

    func testRapidTabSwitchingAndBackgroundKeepState() {
        let tabs = ["Tələbələr", "Qruplar", "Müəllimlər", "Ana səhifə"]

        for index in 0..<20 {
            app.tabBars.buttons[tabs[index % tabs.count]].tap()
        }

        XCTAssertTrue(app.staticTexts["employee_greeting"].waitForExistence(timeout: uiTimeout))

        let student = app.buttons["student_row_11"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Tələbələr"], until: student))
        XCTAssertTrue(app.tap(student, until: app.staticTexts["student_detail_name"]))

        XCUIDevice.shared.press(.home)
        app.activate()

        XCTAssertTrue(app.staticTexts["student_detail_name"].waitForExistence(timeout: uiTimeout))
        XCTAssertEqual(app.staticTexts["student_detail_name"].label, "Nihad Məmmədov")

        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(student.waitForExistence(timeout: uiTimeout))
        XCTAssertFalse(app.descendants(matching: .any)["loading_view"].exists)
    }
}
