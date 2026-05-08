# Sentinel

Sentinel is a free and open-source macOS menu-bar utility that locks the physical keyboard, mouse, and trackpad while leaving the screen on and apps running. Unlock uses Touch ID or the account password.

> Screenshots and a demo GIF will be added before the first public release.

## Why This Exists

Long-running AI agents, renders, ML training jobs, downloads, and remote sessions often need the Mac to stay awake with the monitor visible while you step away. Sentinel keeps the work visible and running while blocking local physical input until you authenticate again.

## Install

After the first release:

```sh
brew tap prithvi-bharadwaj/sentinel
brew install --cask sentinel
```

The cask lives in this repository under `Casks/sentinel.rb`.

## How It Works

Sentinel installs an active `CGEventTap` at the session level while locked. The tap receives keyboard, mouse, scroll, drag, and tablet events before regular apps and returns `nil` to consume them. The unlock chord is recognized inside that tap so the chord itself is consumed too, then Touch ID or password authentication decides whether the lock is released.

## Permissions

Sentinel requires Accessibility permission because macOS only allows trusted apps to install an event tap that can intercept input. Sentinel does not need Full Disk Access, Screen Recording, network access, or telemetry permission. Accessibility lets Sentinel observe and block local input events while locked; it does not grant access to your passwords or private files.

## Security Model

Sentinel has no network client, no telemetry, and no update pings. The app stores settings in `UserDefaults`, uses Apple's LocalAuthentication framework for unlock, and releases all event taps and power assertions on unlock or quit. It is open source so the behavior can be inspected directly.

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
