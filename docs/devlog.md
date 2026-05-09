# Devlog

## Phase 1 - Scaffold

- Initialized the monorepo layout for the SwiftUI menu-bar app, local Swift packages, CI, release scripts, docs, and Homebrew cask.
- Added baseline project documentation, MIT license, SwiftLint config, and swift-format config.

## Phase 2 - Core Logic

- Implemented `SentinelCore` with typed errors, lock state, settings persistence, unlock chord parsing, and Core Graphics event-mask construction.
- Added unit tests for defaults, persistence, chord parsing, and required event-mask coverage.

## Phase 3 - Apple API Packages

- Implemented `SentinelInput` with an injectable event-tapping boundary and an actor-owned `CGEventTap` lifecycle.
- Implemented `SentinelAuth` with an injectable `LAContextProtocol` and `.deviceOwnerAuthentication` evaluation.
- Implemented `SentinelPower` with an injectable IOKit assertion boundary.
- Implemented `SentinelOverlay` with one screen-saver-level window per display and a SwiftUI lock view.
- Gotcha: IOKit assertion constants are imported as `String` in Swift, so the adapter bridges them to `CFString` only at the `IOPMAssertionCreateWithName` call.

## Phase 4 - App Target

- Added the XcodeGen `project.yml`, macOS app Info.plist, menu-bar controller, settings scene, Accessibility onboarding window, and actor-based lock controller.
- Wired `KeyboardShortcuts` for the lock hotkey and kept the unlock chord inside the input tap path.
- Added a UI persistence smoke test target. Local `xcodebuild test` built the runner but could not initialize UI automation in this non-interactive session because macOS requested authentication; `xcodebuild build` succeeds.
- Added a hosted app unit test to the default `Sentinel` scheme so `xcodebuild test` runs in CI without UI automation approval.

## Phase 5 - CI and Release

- Added CI for Swift package tests, SwiftLint, XcodeGen project generation, and `xcodebuild test` on macOS 14.
- Added a tag-based release workflow that builds, ad-hoc signs, packages a DMG, creates a GitHub Release, and updates the Homebrew cask.
- Added release helper scripts and the initial `Casks/sentinel.rb` formula with `USER` placeholders pending the final GitHub owner.
- Verified a local ad-hoc signed DMG build at `release/Sentinel-0.1.0.dmg`; latest SHA256 was `c2379c697c3373c86180788f33ff3b9dc8c8d71461c07163e2d761a3a6`.
- Installed SwiftLint locally, fixed the generated `.build` exclusion pattern, and verified `swiftlint` completes with 0 violations.
- Filled the Homebrew cask owner as `prithvi-bharadwaj` based on the active GitHub CLI account.
- Published `v0.1.0` to GitHub and verified `brew install --cask prithvi-bharadwaj/sentinel/sentinel` installs `/Applications/Sentinel.app`.
- Gotcha: unqualified `brew install --cask sentinel` resolves to HashiCorp's existing Sentinel cask, so documentation uses the fully qualified tap token.
