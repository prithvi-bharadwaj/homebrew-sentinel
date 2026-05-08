import CoreGraphics
import Foundation
import OSLog
import SentinelCore

/// Actor that owns the active Core Graphics event tap while Sentinel is locked.
public actor InputBlocker {
    private let eventTapping: any EventTapping
    private var session: InputBlockerSession?
    private let logger = Logger(subsystem: "org.localhost.sentinel", category: "input")

    /// Creates an input blocker with injectable event tapping.
    public init(eventTapping: any EventTapping = CoreGraphicsEventTapping()) {
        self.eventTapping = eventTapping
    }

    /// Starts blocking input with no unlock callback.
    public func start(unlockChord: UnlockChord) async throws {
        try await start(unlockChord: unlockChord, onUnlockChord: {})
    }

    /// Starts blocking input and invokes `onUnlockChord` when the whitelisted chord is consumed.
    public func start(unlockChord: UnlockChord, onUnlockChord: @escaping @Sendable () -> Void) async throws {
        guard session == nil else {
            throw SentinelError.eventTapAlreadyRunning
        }

        let callbackBox = EventTapCallbackBox(
            unlockChord: unlockChord,
            onUnlockChord: onUnlockChord,
            eventTapping: eventTapping
        )
        let retainedCallbackBox = Unmanaged.passRetained(callbackBox)
        let userInfo = retainedCallbackBox.toOpaque()

        guard
            let tap = eventTapping.createTap(
                mask: SentinelEventMask.cgEventMask,
                callback: sentinelEventTapCallback,
                userInfo: userInfo
            )
        else {
            retainedCallbackBox.release()
            throw SentinelError.eventTapCreationFailed
        }
        callbackBox.setTap(tap)

        guard let source = eventTapping.createRunLoopSource(for: tap) else {
            retainedCallbackBox.release()
            eventTapping.enable(tap, enabled: false)
            throw SentinelError.eventTapCreationFailed
        }

        eventTapping.addToMainRunLoop(source)
        eventTapping.enable(tap, enabled: true)
        session = InputBlockerSession(tap: tap, source: source, callbackBox: retainedCallbackBox)
        logger.info("Input blocker started")
    }

    /// Stops blocking input and releases the tap resources.
    public func stop() async {
        guard let session else {
            return
        }
        eventTapping.enable(session.tap, enabled: false)
        eventTapping.removeFromMainRunLoop(session.source)
        session.callbackBox.release()
        self.session = nil
        logger.info("Input blocker stopped")
    }
}

private struct InputBlockerSession: @unchecked Sendable {
    let tap: EventTapHandle
    let source: RunLoopSourceHandle
    let callbackBox: Unmanaged<EventTapCallbackBox>
}

private final class EventTapCallbackBox: @unchecked Sendable {
    private let unlockChord: UnlockChord
    private let onUnlockChord: @Sendable () -> Void
    private let eventTapping: any EventTapping
    private let lock = NSLock()
    private var tap: EventTapHandle?

    init(
        unlockChord: UnlockChord,
        onUnlockChord: @escaping @Sendable () -> Void,
        eventTapping: any EventTapping
    ) {
        self.unlockChord = unlockChord
        self.onUnlockChord = onUnlockChord
        self.eventTapping = eventTapping
    }

    func setTap(_ tap: EventTapHandle) {
        lock.withLock {
            self.tap = tap
        }
    }

    func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = lock.withLock({ self.tap }) {
                eventTapping.enable(tap, enabled: true)
            }
            return Unmanaged.passUnretained(event)
        }

        if type == .keyDown {
            let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
            if unlockChord.matches(keyCode: keyCode, cgEventFlags: event.flags) {
                onUnlockChord()
                return nil
            }
        }

        return nil
    }
}

private func sentinelEventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else {
        return nil
    }
    let callbackBox = Unmanaged<EventTapCallbackBox>.fromOpaque(userInfo).takeUnretainedValue()
    return callbackBox.handle(type: type, event: event)
}
