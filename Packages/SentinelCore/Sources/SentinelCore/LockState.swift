/// The high-level lifecycle state of the Sentinel lock.
public enum LockState: String, Codable, Equatable, Sendable {
    /// Input is not blocked.
    case unlocked
    /// Sentinel is acquiring permissions, power assertions, overlays, and input taps.
    case locking
    /// Input is blocked and overlays are visible.
    case locked
    /// Sentinel is authenticating and releasing lock resources.
    case unlocking
    /// The last lock or unlock transition failed.
    case failed
}
