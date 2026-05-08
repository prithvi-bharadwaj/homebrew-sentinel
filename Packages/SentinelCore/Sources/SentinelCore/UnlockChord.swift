import CoreGraphics
import Foundation

/// A keyboard chord that can request unlock while the event tap is swallowing input.
public struct UnlockChord: Codable, Equatable, Sendable {
    /// The hardware virtual key code.
    public var keyCode: UInt16
    /// Required modifier flags.
    public var modifiers: ModifierFlags

    /// Sentinel's default unlock chord: Command-Shift-U.
    public static let `default` = UnlockChord(keyCode: 32, modifiers: [.command, .shift])

    /// Creates an unlock chord from a virtual key code and modifiers.
    public init(keyCode: UInt16, modifiers: ModifierFlags) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    /// Parses a display string such as `⌘⇧U` or `cmd+shift+u`.
    public init(displayString: String) throws {
        let normalized = displayString
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: " ", with: "")
            .uppercased()

        var modifiers: ModifierFlags = []
        var remainder = normalized

        let tokens: [(String, ModifierFlags)] = [
            ("COMMAND", .command), ("CMD", .command), ("⌘", .command),
            ("SHIFT", .shift), ("⇧", .shift),
            ("OPTION", .option), ("OPT", .option), ("ALT", .option), ("⌥", .option),
            ("CONTROL", .control), ("CTRL", .control), ("⌃", .control)
        ]

        var consumed = true
        while consumed {
            consumed = false
            for (token, flag) in tokens where remainder.hasPrefix(token) {
                modifiers.insert(flag)
                remainder.removeFirst(token.count)
                consumed = true
            }
        }

        guard !remainder.isEmpty, let keyCode = KeyCodeMap.keyCode(for: remainder) else {
            throw SentinelError.invalidShortcut(displayString)
        }

        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    /// Returns true when the incoming key code and modifier flags match this chord exactly.
    public func matches(keyCode: UInt16, modifiers incomingModifiers: ModifierFlags) -> Bool {
        keyCode == self.keyCode && incomingModifiers == modifiers
    }

    /// Returns true when a Core Graphics keyboard event matches this chord exactly.
    public func matches(keyCode: UInt16, cgEventFlags: CGEventFlags) -> Bool {
        matches(keyCode: keyCode, modifiers: ModifierFlags(cgEventFlags: cgEventFlags))
    }

    /// A compact display string using standard macOS modifier symbols.
    public var displayString: String {
        "\(modifiers.displayString)\(KeyCodeMap.key(for: keyCode) ?? "#\(keyCode)")"
    }
}
