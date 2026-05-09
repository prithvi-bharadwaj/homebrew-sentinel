import SentinelCore
@testable import SentinelOverlay
import XCTest

final class OverlayConfigurationTests: XCTestCase {
    func testConfigurationUsesSettingsDisplayValues() {
        var settings = Settings.defaults
        settings.blurScreenWhenLocked = false
        settings.unlockChord = UnlockChord(keyCode: 37, modifiers: [.command, .shift])

        let configuration = OverlayConfiguration(settings: settings)

        XCTAssertEqual(configuration.unlockChordDisplay, "⌘⇧L")
        XCTAssertFalse(configuration.blurScreen)
    }
}
