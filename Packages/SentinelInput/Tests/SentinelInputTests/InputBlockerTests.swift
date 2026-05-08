import CoreGraphics
import SentinelCore
@testable import SentinelInput
import XCTest

final class InputBlockerTests: XCTestCase {
    func testStartCreatesTapWithSentinelMaskAndEnablesIt() async throws {
        let fake = FakeEventTapping()
        let blocker = InputBlocker(eventTapping: fake)

        try await blocker.start(unlockChord: .default)

        XCTAssertEqual(fake.createdMasks, [SentinelEventMask.cgEventMask])
        XCTAssertEqual(fake.addedSources, 1)
        XCTAssertEqual(fake.enableCalls, [true])
    }

    func testStopDisablesAndRemovesRunLoopSource() async throws {
        let fake = FakeEventTapping()
        let blocker = InputBlocker(eventTapping: fake)

        try await blocker.start(unlockChord: .default)
        await blocker.stop()

        XCTAssertEqual(fake.enableCalls, [true, false])
        XCTAssertEqual(fake.removedSources, 1)
    }

    func testStartThrowsWhenAlreadyRunning() async throws {
        let fake = FakeEventTapping()
        let blocker = InputBlocker(eventTapping: fake)

        try await blocker.start(unlockChord: .default)

        do {
            try await blocker.start(unlockChord: .default)
            XCTFail("Expected start to throw")
        } catch let error as SentinelError {
            XCTAssertEqual(error, .eventTapAlreadyRunning)
        }
    }
}

private final class FakeEventTapping: EventTapping, @unchecked Sendable {
    private let lock = NSLock()
    private(set) var createdMasks: [CGEventMask] = []
    private(set) var addedSources = 0
    private(set) var removedSources = 0
    private(set) var enableCalls: [Bool] = []

    func createTap(
        mask: CGEventMask,
        callback: @escaping CGEventTapCallBack,
        userInfo: UnsafeMutableRawPointer?
    ) -> EventTapHandle? {
        lock.withLock {
            createdMasks.append(mask)
        }
        return EventTapHandle(port: nil)
    }

    func createRunLoopSource(for tap: EventTapHandle) -> RunLoopSourceHandle? {
        RunLoopSourceHandle(source: nil)
    }

    func addToMainRunLoop(_ source: RunLoopSourceHandle) {
        lock.withLock {
            addedSources += 1
        }
    }

    func removeFromMainRunLoop(_ source: RunLoopSourceHandle) {
        lock.withLock {
            removedSources += 1
        }
    }

    func enable(_ tap: EventTapHandle, enabled: Bool) {
        lock.withLock {
            enableCalls.append(enabled)
        }
    }
}
