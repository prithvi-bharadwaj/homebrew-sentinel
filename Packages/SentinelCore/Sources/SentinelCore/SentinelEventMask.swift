import CoreGraphics

/// Builds the Core Graphics event mask Sentinel blocks while locked.
public enum SentinelEventMask {
    /// Event types Sentinel consumes while locked.
    public static let blockedEventTypes: [CGEventType] = [
        .null,
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

    /// The `CGEventMask` passed to `CGEvent.tapCreate`.
    public static var cgEventMask: CGEventMask {
        blockedEventTypes.reduce(CGEventMask(0)) { mask, eventType in
            mask | (CGEventMask(1) << UInt64(eventType.rawValue))
        }
    }

    /// Returns true when the event type is included in Sentinel's blocked mask.
    public static func contains(_ eventType: CGEventType) -> Bool {
        blockedEventTypes.contains(eventType)
    }
}
