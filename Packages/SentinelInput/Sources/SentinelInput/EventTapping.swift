import CoreGraphics
import Foundation

/// Opaque handle for a Core Graphics event tap.
public final class EventTapHandle: @unchecked Sendable {
    fileprivate let port: CFMachPort?

    /// Creates a handle from an optional Mach port.
    public init(port: CFMachPort?) {
        self.port = port
    }
}

/// Opaque handle for the event tap run-loop source.
public final class RunLoopSourceHandle: @unchecked Sendable {
    fileprivate let source: CFRunLoopSource?

    /// Creates a handle from an optional run-loop source.
    public init(source: CFRunLoopSource?) {
        self.source = source
    }
}

/// Dependency boundary for creating and controlling event taps.
public protocol EventTapping: Sendable {
    /// Creates a session event tap.
    func createTap(
        mask: CGEventMask,
        callback: @escaping CGEventTapCallBack,
        userInfo: UnsafeMutableRawPointer?
    ) -> EventTapHandle?

    /// Creates a run-loop source for the tap.
    func createRunLoopSource(for tap: EventTapHandle) -> RunLoopSourceHandle?

    /// Adds a run-loop source to the main run loop in common modes.
    func addToMainRunLoop(_ source: RunLoopSourceHandle)

    /// Removes a run-loop source from the main run loop in common modes.
    func removeFromMainRunLoop(_ source: RunLoopSourceHandle)

    /// Enables or disables an event tap.
    func enable(_ tap: EventTapHandle, enabled: Bool)
}

/// Production `EventTapping` backed by Core Graphics.
public struct CoreGraphicsEventTapping: EventTapping {
    /// Creates a Core Graphics event tapping adapter.
    public init() {}

    /// Creates the active session event tap Sentinel uses to consume input.
    public func createTap(
        mask: CGEventMask,
        callback: @escaping CGEventTapCallBack,
        userInfo: UnsafeMutableRawPointer?
    ) -> EventTapHandle? {
        guard
            let port = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: mask,
                callback: callback,
                userInfo: userInfo
            )
        else {
            return nil
        }
        return EventTapHandle(port: port)
    }

    /// Creates the run-loop source for a Core Graphics event tap.
    public func createRunLoopSource(for tap: EventTapHandle) -> RunLoopSourceHandle? {
        guard let port = tap.port else {
            return nil
        }
        guard let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, 0) else {
            return nil
        }
        return RunLoopSourceHandle(source: source)
    }

    /// Adds the tap source to the main run loop using common modes.
    public func addToMainRunLoop(_ source: RunLoopSourceHandle) {
        guard let source = source.source else {
            return
        }
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
    }

    /// Removes the tap source from the main run loop using common modes.
    public func removeFromMainRunLoop(_ source: RunLoopSourceHandle) {
        guard let source = source.source else {
            return
        }
        CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
    }

    /// Enables or disables the Core Graphics tap.
    public func enable(_ tap: EventTapHandle, enabled: Bool) {
        guard let port = tap.port else {
            return
        }
        CGEvent.tapEnable(tap: port, enable: enabled)
    }
}
