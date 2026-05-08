import SentinelCore

/// Immutable overlay rendering options derived from stored settings.
public struct OverlayConfiguration: Equatable, Sendable {
    /// The unlock chord text shown to the user.
    public var unlockChordDisplay: String
    /// Whether the visible screen should be blurred.
    public var blurScreen: Bool
    /// Whether an unlock button should be visible.
    public var showUnlockButton: Bool

    /// Creates an overlay configuration.
    public init(unlockChordDisplay: String, blurScreen: Bool, showUnlockButton: Bool) {
        self.unlockChordDisplay = unlockChordDisplay
        self.blurScreen = blurScreen
        self.showUnlockButton = showUnlockButton
    }

    /// Creates an overlay configuration from stored settings.
    public init(settings: Settings) {
        self.init(
            unlockChordDisplay: settings.unlockChord.displayString,
            blurScreen: settings.blurScreenWhenLocked,
            showUnlockButton: settings.showUnlockButtonOnOverlay
        )
    }
}
