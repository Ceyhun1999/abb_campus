import XCTest

@MainActor
final class LoginUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = .launchedForUITesting()
    }

    // MARK: - Tests

    func testSelectingStudentRoleOpensLoginScreen() {
        XCTAssertTrue(app.openLogin(role: "student"))

        XCTAssertEqual(app.staticTexts["login_title"].label, "Tələbə girişi")
        XCTAssertTrue(app.textFields["login_email"].exists)
        XCTAssertTrue(app.secureTextFields["login_password"].exists)
        XCTAssertTrue(app.buttons["login_button"].exists)
    }

    func testEmptyFieldsShowValidationError() {
        XCTAssertTrue(app.openLogin(role: "student"))

        app.buttons["login_button"].tap()

        let error = app.staticTexts["login_error"]
        XCTAssertTrue(error.waitForExistence(timeout: uiTimeout))
        XCTAssertEqual(error.label, "E-poçtu daxil edin.")
    }

    func testWrongPasswordShowsServerError() {
        XCTAssertTrue(app.openLogin(role: "student"))

        app.fillCredentials(email: "student@abb.local", password: "WrongPass1")
        app.buttons["login_button"].tap()

        let error = app.staticTexts["login_error"]
        XCTAssertTrue(error.waitForExistence(timeout: uiTimeout))
        XCTAssertEqual(error.label, "Bu məlumatlarla hesab tapılmadı.")
    }

    func testSuccessfulLoginOpensStudentHomeAndLogoutReturnsToRoles() {
        XCTAssertTrue(app.openLogin(role: "student"))

        app.fillCredentials(email: "student@abb.local", password: "Password123!")
        app.buttons["login_button"].tap()

        let greeting = app.staticTexts["home_greeting"]
        XCTAssertTrue(greeting.waitForExistence(timeout: uiTimeout))
        XCTAssertEqual(greeting.label, "Salam, Ceyhun!")

        let logoutButton = app.buttons["logout_button"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Profil"], until: logoutButton))

        let confirmLogout = app.buttons["confirm_logout_button"].firstMatch
        XCTAssertTrue(app.tap(logoutButton, until: confirmLogout))
        confirmLogout.tap()

        XCTAssertTrue(app.buttons["role_student"].waitForExistence(timeout: uiTimeout))
    }

    func testForgotPasswordOpensSheet() {
        XCTAssertTrue(app.openLogin(role: "student"))

        app.buttons["forgot_password_button"].tap()

        XCTAssertTrue(app.textFields["forgot_password_email"].waitForExistence(timeout: uiTimeout))
        XCTAssertTrue(app.buttons["forgot_password_submit"].exists)
    }
}
