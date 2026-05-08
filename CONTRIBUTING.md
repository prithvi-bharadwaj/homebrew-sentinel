# Contributing

Sentinel is a small macOS utility with security-sensitive behavior. Keep changes narrow, tested, and easy to audit.

## Workflow

1. Create a branch for the package or feature you are changing.
2. Run the relevant package tests.
3. Run `xcodegen generate` and the app test suite when touching app wiring.
4. Run SwiftLint before opening a pull request.
5. Add a short note to `docs/devlog.md` for completed phases or notable Apple API gotchas.

## Code Standards

- Public types and public methods need doc comments.
- Use typed Swift errors instead of `NSError` in project code.
- Do not add network clients, telemetry, or analytics.
- Do not force-unwrap in production code paths.
- Prefer dependency injection around Apple APIs that need permissions or hardware.

## Manual Testing

Real input blocking requires Accessibility permission and cannot be fully covered by unit tests. Follow `docs/manual-testing.md` before release.
