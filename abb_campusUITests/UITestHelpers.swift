import XCTest

/// CI simulators are much slower than a local Mac, so waits are generous.
let uiTimeout: TimeInterval = 20

extension XCUIApplication {

    static func launchedForUITesting() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        return app
    }

    /// Taps `element` until `target` appears.
    ///
    /// After a login iOS may show a "Save Password?" prompt with a delay,
    /// and its window can swallow a tap even after it is dismissed, so the
    /// prompt is closed (first button is "Not Now" in any language) and the
    /// tap is retried.
    @discardableResult
    func tap(
        _ element: XCUIElement,
        until target: XCUIElement,
        timeout: TimeInterval = 40
    ) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if target.exists {
                return true
            }

            let savePasswordPrompt = sheets.firstMatch

            if savePasswordPrompt.exists {
                savePasswordPrompt.buttons.element(boundBy: 0).tap()
            } else if element.exists && element.isHittable {
                // A coordinate tap never fails the test: if the prompt
                // appears in between, the loop simply tries again.
                element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

                if target.waitForExistence(timeout: 3) {
                    return true
                }
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        }

        return target.exists
    }

    /// Opens the login screen for `role`, retrying if a busy simulator drops the tap.
    func openLogin(role: String) -> Bool {
        let roleButton = buttons["role_\(role)"]

        guard roleButton.waitForExistence(timeout: uiTimeout) else {
            return false
        }

        return tap(roleButton, until: buttons["login_button"])
    }

    func fillCredentials(email: String, password: String) {
        let emailField = textFields["login_email"]
        emailField.tap()
        emailField.typeText(email)

        let passwordField = secureTextFields["login_password"]
        passwordField.tap()
        passwordField.typeText(password)
    }
}

extension XCUIElement {

    func waitForDisappearance(timeout: TimeInterval = uiTimeout) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: self
        )

        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
}
