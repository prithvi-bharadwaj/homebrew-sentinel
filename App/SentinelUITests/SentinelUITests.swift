import XCTest

final class SentinelUITests: XCTestCase {
    func testSettingsPersistenceSmoke() {
        let app = XCUIApplication()
        app.launchArguments = ["--open-settings"]
        app.launch()

        let blurCheckbox = app.checkBoxes["Blur screen when locked"]
        XCTAssertTrue(blurCheckbox.waitForExistence(timeout: 5))

        let originalValue = blurCheckbox.value as? String
        blurCheckbox.click()
        app.terminate()

        let relaunched = XCUIApplication()
        relaunched.launchArguments = ["--open-settings"]
        relaunched.launch()

        let relaunchedBlurCheckbox = relaunched.checkBoxes["Blur screen when locked"]
        XCTAssertTrue(relaunchedBlurCheckbox.waitForExistence(timeout: 5))
        XCTAssertNotEqual(relaunchedBlurCheckbox.value as? String, originalValue)
        relaunched.terminate()
    }
}
