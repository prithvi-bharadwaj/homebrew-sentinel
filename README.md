# Sentinel

Sentinel is a free and open-source macOS menu-bar utility that locks the physical keyboard, mouse, and trackpad while leaving the screen on and apps running. Unlock uses Touch ID or the account password.

## Screenshots

Screenshots and a demo GIF placeholder live here until visual assets are captured from the signed app.

## Why This Exists

Long-running AI agents, renders, ML training jobs, downloads, and remote sessions often need the Mac to stay awake with the monitor visible while you step away. Sentinel keeps the work visible and running while blocking local physical input until you authenticate again.

## Install

```sh
brew tap prithvi-bharadwaj/sentinel
brew install --cask prithvi-bharadwaj/sentinel/sentinel
```

The cask lives in this repository under `Casks/sentinel.rb`. Use the fully qualified cask token because Homebrew's core cask tap already contains HashiCorp's `sentinel` cask.

## How It Works

Sentinel installs an active `CGEventTap` at the session level while locked. The tap receives keyboard, mouse, scroll, drag, and tablet events before regular apps and returns `nil` to consume them. The unlock chord is recognized inside that tap so the chord itself is consumed too, then Touch ID or password authentication decides whether the lock is released.

## Permissions

Sentinel requires Accessibility permission because macOS only allows trusted apps to install an event tap that can intercept input. Sentinel does not need Full Disk Access, Screen Recording, network access, or telemetry permission. Accessibility lets Sentinel observe and block local input events while locked; it does not grant access to your passwords or private files.

## Threat Model

Sentinel is convenience tooling for blocking accidental local input while the screen stays on. It is not a security boundary. Treat it the way you would a "do not disturb" sign, not a deadbolt.

What Sentinel does block: keyboard, mouse, scroll, and trackpad events delivered through the session-level `CGEventTap` while the lock is active. The unlock chord is consumed inside the tap so the chord characters do not leak to other apps after unlock.

What Sentinel does **not** block, by design or by architectural limit:

- A user with shell access on the same machine can `kill` the Sentinel process. The event tap is in-process and dies with it.
- System-defined and hardware-level events outside `CGEventTap`'s reach: power button, lid close, `Ctrl-Cmd-Power` hard restart, media keys delivered as `NSSystemDefined`, Touch Bar system actions.
- Other already-trusted Accessibility clients (UI scripting, automation tools) that drive the UI through the AX API instead of synthesized input events.
- Remote sessions (SSH, Screen Sharing, MDM) — Sentinel does not interpose on those paths.

For privacy, Sentinel has no network client, no telemetry, and no update pings. Settings are stored in `UserDefaults`. Unlock uses Apple's `LocalAuthentication` framework. Event taps and power assertions are released on graceful quit. The source is open so behavior can be inspected directly.

If you need a real security lock against a present-and-motivated adversary, use macOS's built-in lock screen (`Ctrl-Cmd-Q`) instead.

## Build From Source

Requirements:

- macOS 14.0+
- Xcode 15.0+ or newer
- XcodeGen

```sh
xcodegen generate
swift test --package-path Packages/SentinelCore
swift test --package-path Packages/SentinelInput
swift test --package-path Packages/SentinelAuth
swift test --package-path Packages/SentinelPower
swift test --package-path Packages/SentinelOverlay
xcodebuild test -project Sentinel.xcodeproj -scheme Sentinel -destination 'platform=macOS'
```

SwiftLint is enforced in CI. Install it locally with Homebrew if you want the same check before pushing:

```sh
brew install swiftlint
swiftlint
```

## Development Layout

```text
App/                 macOS menu-bar app target
Packages/            local Swift packages with testable logic
Scripts/             build and release helpers
Casks/               Homebrew cask formula
docs/                manual test plans and devlog
.github/workflows/   CI and release automation
```

## Contributing

See `CONTRIBUTING.md`. Please include tests for behavioral changes and update `docs/devlog.md` when finishing a phase.

## License

MIT. See `LICENSE`.
