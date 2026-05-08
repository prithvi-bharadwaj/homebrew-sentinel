import Foundation

/// Typed errors emitted by Sentinel packages.
public enum SentinelError: Error, Equatable, LocalizedError, Sendable {
    /// Accessibility permission is required before input can be blocked.
    case accessibilityPermissionDenied
    /// A Core Graphics event tap could not be created.
    case eventTapCreationFailed
    /// The event tap is already running.
    case eventTapAlreadyRunning
    /// The event tap is not currently running.
    case eventTapNotRunning
    /// Device owner authentication is unavailable.
    case authenticationUnavailable(String)
    /// Device owner authentication failed.
    case authenticationFailed(String)
    /// A power assertion could not be created.
    case powerAssertionFailed(String)
    /// A shortcut string could not be parsed.
    case invalidShortcut(String)

    /// A human-readable description for logs and UI.
    public var errorDescription: String? {
        switch self {
        case .accessibilityPermissionDenied:
            return "Accessibility permission is required."
        case .eventTapCreationFailed:
            return "Sentinel could not create a Core Graphics event tap."
        case .eventTapAlreadyRunning:
            return "The input blocker is already running."
        case .eventTapNotRunning:
            return "The input blocker is not running."
        case let .authenticationUnavailable(reason):
            return "Authentication is unavailable: \(reason)"
        case let .authenticationFailed(reason):
            return "Authentication failed: \(reason)"
        case let .powerAssertionFailed(reason):
            return "Power assertion failed: \(reason)"
        case let .invalidShortcut(shortcut):
            return "Invalid shortcut: \(shortcut)"
        }
    }
}
