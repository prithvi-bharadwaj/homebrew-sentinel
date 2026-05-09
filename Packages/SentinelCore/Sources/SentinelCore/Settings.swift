import Foundation
import SwiftUI

/// Stored Sentinel preferences.
public struct Settings: Codable, Equatable, Sendable {
    /// Start Sentinel at login via `SMAppService.mainApp`.
    public var launchAtLogin: Bool
    /// Show the status item in the menu bar.
    public var showMenuBarIcon: Bool
    /// Prevent display and idle system sleep while locked.
    public var preventSleepWhenLocked: Bool
    /// Prevent system sleep while locked, including lid-closed scenarios where macOS permits it.
    public var preventSleepWithLidClosed: Bool
    /// Blur the visible screen content behind the lock overlay.
    public var blurScreenWhenLocked: Bool
    /// Stored display form for the lock shortcut. KeyboardShortcuts owns the active global registration.
    public var lockShortcutDisplay: String
    /// Unlock chord recognized inside the event tap.
    public var unlockChord: UnlockChord

    /// Production defaults documented inline.
    public static let defaults = Settings(
        launchAtLogin: false,
        showMenuBarIcon: true,
        preventSleepWhenLocked: true,
        preventSleepWithLidClosed: false,
        blurScreenWhenLocked: true,
        lockShortcutDisplay: "⌘⇧L",
        unlockChord: .default
    )

    /// Creates a settings value.
    public init(
        launchAtLogin: Bool,
        showMenuBarIcon: Bool,
        preventSleepWhenLocked: Bool,
        preventSleepWithLidClosed: Bool,
        blurScreenWhenLocked: Bool,
        lockShortcutDisplay: String,
        unlockChord: UnlockChord
    ) {
        self.launchAtLogin = launchAtLogin
        self.showMenuBarIcon = showMenuBarIcon
        self.preventSleepWhenLocked = preventSleepWhenLocked
        self.preventSleepWithLidClosed = preventSleepWithLidClosed
        self.blurScreenWhenLocked = blurScreenWhenLocked
        self.lockShortcutDisplay = lockShortcutDisplay
        self.unlockChord = unlockChord
    }
}

/// Observable settings persistence backed by `UserDefaults` through `@AppStorage`.
@MainActor
public final class SettingsStore: ObservableObject {
    /// The `UserDefaults` key storing encoded settings.
    public nonisolated static let userDefaultsKey = "org.localhost.sentinel.settings"

    @AppStorage(SettingsStore.userDefaultsKey) private var encodedSettings: Data = SettingsStore.encode(.defaults)

    /// The currently decoded settings value.
    @Published public private(set) var settings: Settings

    /// Creates a settings store using a specific defaults suite.
    public init(userDefaults: UserDefaults = .standard) {
        let defaultData = Self.encode(.defaults)
        _encodedSettings = AppStorage(wrappedValue: defaultData, Self.userDefaultsKey, store: userDefaults)
        let storedData = userDefaults.data(forKey: Self.userDefaultsKey) ?? defaultData
        _settings = Published(initialValue: Self.decode(storedData))
    }

    /// Replaces all settings and persists them.
    public func replace(with settings: Settings) {
        self.settings = settings
        encodedSettings = Self.encode(settings)
    }

    /// Mutates settings and persists the result.
    public func update(_ transform: (inout Settings) -> Void) {
        var nextSettings = settings
        transform(&nextSettings)
        replace(with: nextSettings)
    }

    /// Restores production defaults.
    public func reset() {
        replace(with: .defaults)
    }

    private static func encode(_ settings: Settings) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return (try? encoder.encode(settings)) ?? Data()
    }

    private static func decode(_ data: Data) -> Settings {
        guard !data.isEmpty else {
            return .defaults
        }
        return (try? JSONDecoder().decode(Settings.self, from: data)) ?? .defaults
    }
}
