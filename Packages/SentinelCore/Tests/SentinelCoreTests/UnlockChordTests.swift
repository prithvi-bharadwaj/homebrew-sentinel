import CoreGraphics
@testable import SentinelCore
import XCTest

final class UnlockChordTests: XCTestCase {
    func testDefaultUnlockChordIsCommandShiftU() {
        XCTAssertEqual(UnlockChord.default.keyCode, 32)
        XCTAssertEqual(UnlockChord.default.modifiers, [.command, .shift])
        XCTAssertEqual(UnlockChord.default.displayString, "⌘⇧U")
    }

    func testParsesSymbolShortcut() throws {
        let chord = try UnlockChord(displayString: "⌘⇧U")
        XCTAssertEqual(chord, .default)
    }

    func testParsesWordShortcut() throws {
        let chord = try UnlockChord(displayString: "cmd+shift+l")
        XCTAssertEqual(chord.keyCode, 37)
        XCTAssertEqual(chord.modifiers, [.command, .shift])
    }

    func testRejectsUnknownShortcut() {
        XCTAssertThrowsError(try UnlockChord(displayString: "cmd+shift+space"))
    }

    func testMatchesCoreGraphicsFlags() {
        XCTAssertTrue(
            UnlockChord.default.matches(
                keyCode: 32,
                cgEventFlags: [.maskCommand, .maskShift]
            )
        )
        XCTAssertFalse(
            UnlockChord.default.matches(
                keyCode: 32,
                cgEventFlags: [.maskCommand, .maskAlternate]
            )
        )
    }
}
