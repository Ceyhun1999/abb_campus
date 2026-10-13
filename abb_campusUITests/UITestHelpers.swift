import XCTest

let uiTimeout: TimeInterval = 20

extension XCUIApplication {

    static func launchedForUITesting() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        return app
    }

    // MARK: - Tap

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
                element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

                if target.waitForExistence(timeout: 3) {
                    return true
                }
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        }

        return target.exists
    }

    // MARK: - Login

    func openLogin(role: String) -> Bool {
        let roleButton = buttons["role_\(role)"]

        guard roleButton.waitForExistence(timeout: uiTimeout) else {
            return false
        }

        return tap(roleButton, until: buttons["login_button"])
    }

    func fillCredentials(email: String, password: String) {
        textFields["login_email"].type(email)
        secureTextFields["login_password"].type(password)
    }
}

extension XCUIElement {

    // MARK: - Typing

    func type(_ text: String, timeout: TimeInterval = uiTimeout) {
        let focused = NSPredicate(format: "hasKeyboardFocus == true")
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            tap()

            let expectation = XCTNSPredicateExpectation(predicate: focused, object: self)

            if XCTWaiter.wait(for: [expectation], timeout: 3) == .completed {
                typeText(text)
                return
            }
        }

        XCTFail("\(self) did not get keyboard focus within \(timeout)s")
    }

    func waitForDisappearance(timeout: TimeInterval = uiTimeout) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: self
        )

        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
}
