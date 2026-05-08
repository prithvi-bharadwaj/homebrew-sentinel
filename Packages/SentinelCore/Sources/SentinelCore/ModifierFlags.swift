import CoreGraphics

/// Platform-neutral modifier flags used by stored shortcuts and unlock chords.
public struct ModifierFlags: OptionSet, Codable, Equatable, Hashable, Sendable {
    /// Raw bit storage.
    public let rawValue: UInt64

    /// Command modifier.
    public static let command = ModifierFlags(rawValue: 1 << 0)
    /// Shift modifier.
    public static let shift = ModifierFlags(rawValue: 1 << 1)
    /// Option modifier.
    public static let option = ModifierFlags(rawValue: 1 << 2)
    /// Control modifier.
    public static let control = ModifierFlags(rawValue: 1 << 3)

    /// Creates modifier flags from raw storage.
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    /// Creates modifier flags from Core Graphics event flags.
    public init(cgEventFlags: CGEventFlags) {
        var flags: ModifierFlags = []
        if cgEventFlags.contains(.maskCommand) {
            flags.insert(.command)
        }
        if cgEventFlags.contains(.maskShift) {
            flags.insert(.shift)
        }
        if cgEventFlags.contains(.maskAlternate) {
            flags.insert(.option)
        }
        if cgEventFlags.contains(.maskControl) {
            flags.insert(.control)
        }
        self = flags
    }

    /// A compact display string using standard macOS modifier symbols.
    public var displayString: String {
        var result = ""
        if contains(.command) {
            result += "⌘"
        }
        if contains(.shift) {
            result += "⇧"
        }
        if contains(.option) {
            result += "⌥"
        }
        if contains(.control) {
            result += "⌃"
        }
        return result
    }
}
