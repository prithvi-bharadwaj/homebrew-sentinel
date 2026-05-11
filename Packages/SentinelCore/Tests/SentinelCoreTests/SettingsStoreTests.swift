import Foundation
@testable import SentinelCore
import XCTest

@MainActor
final class SettingsStoreTests: XCTestCase {
    func testDefaultsAreDocumentedProductionDefaults() {
        XCTAssertFalse(Settings.defaults.launchAtLogin)
        XCTAssertTrue(Settings.defaults.showMenuBarIcon)
        XCTAssertTrue(Settings.defaults.preventSleepWhenLocked)
        XCTAssertFalse(Settings.defaults.preventSleepWithLidClosed)
        XCTAssertTrue(Settings.defaults.blurScreenWhenLocked)
        XCTAssertEqual(Settings.defaults.unlockChord, .default)
    }

    func testStorePersistsSettings() {
        let suiteName = "SentinelCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Could not create test defaults")
            return
        }
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = SettingsStore(userDefaults: defaults)
        store.update { settings in
            settings.blurScreenWhenLocked = false
            settings.unlockChord = UnlockChord(keyCode: 37, modifiers: [.command, .shift])
        }

        let reloaded = SettingsStore(userDefaults: defaults)
        XCTAssertFalse(reloaded.settings.blurScreenWhenLocked)
        XCTAssertEqual(reloaded.settings.unlockChord.keyCode, 37)
    }
}
