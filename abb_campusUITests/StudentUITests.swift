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
        XCTAssertEqual(totalScore.label, "64 / 75")
    }

    func testStudentSwitchesBetweenDarkAndLightInProfile() {
        XCTAssertTrue(app.openLogin(role: "student"))
        app.fillCredentials(email: "student@abb.local", password: "Password123!")
        app.buttons["login_button"].tap()
        XCTAssertTrue(app.staticTexts["next_lesson_title"].waitForExistence(timeout: uiTimeout))

        let picker = app.segmentedControls["appearance_picker"]
        XCTAssertTrue(app.tap(app.tabBars.buttons["Profil"], until: picker))

        picker.buttons["Qaranlıq"].tap()
        XCTAssertTrue(picker.buttons["Qaranlıq"].isSelected)
        XCTAssertTrue(waitForBrightness { $0 < 0.35 }, "the app turns dark")

        picker.buttons["İşıqlı"].tap()
        XCTAssertTrue(picker.buttons["İşıqlı"].isSelected)
        XCTAssertTrue(waitForBrightness { $0 > 0.65 }, "the app turns light")
    }

    /// Waits for the screen to reach the expected brightness; the change is animated.
    private func waitForBrightness(timeout: TimeInterval = 5, _ isExpected: (CGFloat) -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)

        repeat {
            if isExpected(screenBrightness()) {
                return true
            }

            Thread.sleep(forTimeInterval: 0.3)
        } while Date() < deadline

        return false
    }

    /// Average brightness (0 black … 1 white) of the screen background under the navigation title.
    private func screenBrightness() -> CGFloat {
        guard let image = XCUIScreen.main.screenshot().image.cgImage,
              let data = image.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else {
            return -1
        }

        let bytesPerPixel = image.bitsPerPixel / 8
        var total: CGFloat = 0
        var count: CGFloat = 0

        for y in stride(from: image.height / 10, to: image.height / 6, by: 4) {
            for x in stride(from: image.width * 3 / 4, to: image.width - 10, by: 4) {
                let offset = y * image.bytesPerRow + x * bytesPerPixel
                total += (CGFloat(bytes[offset]) + CGFloat(bytes[offset + 1]) + CGFloat(bytes[offset + 2])) / (3 * 255)
                count += 1
            }
        }

        return count > 0 ? total / count : -1
    }
}
