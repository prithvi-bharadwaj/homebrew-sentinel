import CoreGraphics
@testable import SentinelCore
import XCTest

final class EventMaskTests: XCTestCase {
    func testEventMaskContainsRequiredEventTypes() {
        let required: [CGEventType] = [
            .keyDown,
            .keyUp,
            .flagsChanged,
            .leftMouseDown,
            .leftMouseUp,
            .leftMouseDragged,
            .rightMouseDown,
            .rightMouseUp,
            .rightMouseDragged,
            .otherMouseDown,
            .otherMouseUp,
            .otherMouseDragged,
            .mouseMoved,
            .scrollWheel,
            .tabletPointer,
            .tabletProximity
        ]

        for eventType in required {
            XCTAssertTrue(SentinelEventMask.contains(eventType), "\(eventType) should be blocked")
            XCTAssertNotEqual(SentinelEventMask.cgEventMask & (CGEventMask(1) << UInt64(eventType.rawValue)), 0)
        }
    }
}
