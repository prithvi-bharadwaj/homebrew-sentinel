import SentinelCore

/// Immutable overlay rendering options derived from stored settings.
public struct OverlayConfiguration: Equatable, Sendable {
    /// The unlock chord text shown to the user.
    public var unlockChordDisplay: String
    /// Whether the visible screen should be blurred.
    public var blurScreen: Bool

    /// Creates an overlay configuration.
    public init(unlockChordDisplay: String, blurScreen: Bool) {
        self.unlockChordDisplay = unlockChordDisplay
        self.blurScreen = blurScreen
    }

    /// Creates an overlay configuration from stored settings.
    public init(settings: Settings) {
        self.init(
            unlockChordDisplay: settings.unlockChord.displayString,
            blurScreen: settings.blurScreenWhenLocked
        )
    }
}
