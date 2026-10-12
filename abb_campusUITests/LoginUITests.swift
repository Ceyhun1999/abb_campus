import XCTest

@MainActor
final class LoginUITests: XCTestCase {

    private var app: XCUIApplication!

    /// CI simulators are much slower than a local Mac, so waits are generous.
    private let timeout: TimeInterval = 20

    override func setUp() async throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
    }

    // MARK: - Tests

    func testSelectingStudentRoleOpensLoginScreen() {
        openStudentLogin()

        XCTAssertEqual(app.staticTexts["login_title"].label, "Tələbə girişi")
        XCTAssertTrue(app.textFields["login_email"].exists)
        XCTAssertTrue(app.secureTextFields["login_password"].exists)
        XCTAssertTrue(app.buttons["login_button"].exists)
    }

    func testEmptyFieldsShowValidationError() {
        openStudentLogin()

        app.buttons["login_button"].tap()

        let error = app.staticTexts["login_error"]
        XCTAssertTrue(error.waitForExistence(timeout: timeout))
        XCTAssertEqual(error.label, "E-poçtu daxil edin.")
    }

    func testWrongPasswordShowsServerError() {
        openStudentLogin()

        fillCredentials(email: "student@abb.local", password: "WrongPass1")
        app.buttons["login_button"].tap()

        let error = app.staticTexts["login_error"]
        XCTAssertTrue(error.waitForExistence(timeout: timeout))
        XCTAssertEqual(error.label, "Bu məlumatlarla hesab tapılmadı.")
    }

    func testSuccessfulLoginOpensStudentHomeAndLogoutReturnsToRoles() {
        openStudentLogin()

        fillCredentials(email: "student@abb.local", password: "Password123!")
        app.buttons["login_button"].tap()

        let greeting = app.staticTexts["home_greeting"]
        XCTAssertTrue(greeting.waitForExistence(timeout: timeout))
        XCTAssertEqual(greeting.label, "Salam, Ceyhun!")

        tapWhenHittable(app.tabBars.buttons["Profil"])
        tapWhenHittable(app.buttons["logout_button"])

        let confirmLogout = app.buttons["confirm_logout_button"].firstMatch
        XCTAssertTrue(confirmLogout.waitForExistence(timeout: timeout))
        confirmLogout.tap()

        XCTAssertTrue(app.buttons["role_student"].waitForExistence(timeout: timeout))
    }

    func testForgotPasswordOpensSheet() {
        openStudentLogin()

        app.buttons["forgot_password_button"].tap()

        XCTAssertTrue(app.textFields["forgot_password_email"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["forgot_password_submit"].exists)
    }

    // MARK: - Helpers

    private func openStudentLogin() {
        let studentRole = app.buttons["role_student"]
        XCTAssertTrue(studentRole.waitForExistence(timeout: timeout))
        studentRole.tap()

        XCTAssertTrue(app.buttons["login_button"].waitForExistence(timeout: timeout))
    }

    /// After a successful login iOS may show a "Save Password?" prompt
    /// with a delay. Dismiss it (first button is "Not Now" in any language)
    /// until the element underneath becomes hittable.
    private func tapWhenHittable(
        _ element: XCUIElement,
        timeout: TimeInterval = 40,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            let savePasswordPrompt = app.sheets.firstMatch

            if savePasswordPrompt.exists {
                savePasswordPrompt.buttons.element(boundBy: 0).tap()
            } else if element.exists && element.isHittable {
                element.tap()
                return
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        }

        XCTFail("\(element) was not hittable within \(timeout)s", file: file, line: line)
    }

    private func fillCredentials(email: String, password: String) {
        let emailField = app.textFields["login_email"]
        emailField.tap()
        emailField.typeText(email)

        let passwordField = app.secureTextFields["login_password"]
        passwordField.tap()
        passwordField.typeText(password)
    }
}
