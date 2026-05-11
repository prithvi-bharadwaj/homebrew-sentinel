import Foundation
import OSLog
import SentinelAuth
import SentinelCore
import SentinelInput
import SentinelOverlay
import SentinelPower

actor LockController {
    private let settingsStore: SettingsStore
    private let overlayManager: OverlayWindowManager
    private let onboardingController: AccessibilityOnboardingController
    private let inputBlocker: InputBlocker
    private let authenticator: BiometricAuthenticator
    private let powerManager: PowerAssertionManager
    private let stateDidChange: @MainActor @Sendable (LockState) -> Void
    private let logger = Logger(subsystem: "org.localhost.sentinel", category: "lock")

    private var state: LockState = .unlocked
    private var authenticationInFlight = false

    init(
        settingsStore: SettingsStore,
        overlayManager: OverlayWindowManager,
        onboardingController: AccessibilityOnboardingController,
        inputBlocker: InputBlocker,
        authenticator: BiometricAuthenticator,
        powerManager: PowerAssertionManager,
        stateDidChange: @escaping @MainActor @Sendable (LockState) -> Void
    ) {
        self.settingsStore = settingsStore
        self.overlayManager = overlayManager
        self.onboardingController = onboardingController
        self.inputBlocker = inputBlocker
        self.authenticator = authenticator
        self.powerManager = powerManager
        self.stateDidChange = stateDidChange
    }

    func lock() async {
        guard state == .unlocked || state == .failed else {
            return
        }

        await setState(.locking)

        let isTrusted = await MainActor.run {
            AccessibilityPermission.requestIfNeeded()
        }

        guard isTrusted else {
            await MainActor.run {
                onboardingController.present { [weak self] in
                    self?.requestLock()
                }
            }
            await setState(.unlocked)
            return
        }

        let settings = await MainActor.run {
            settingsStore.settings
        }

        do {
            try powerManager.acquire(
                options: PowerAssertionOptions(
                    preventSleepWhenLocked: settings.preventSleepWhenLocked,
                    preventSleepWithLidClosed: settings.preventSleepWithLidClosed
                )
            )

            await MainActor.run {
                overlayManager.show(configuration: OverlayConfiguration(settings: settings))
            }

            try await inputBlocker.start(unlockChord: settings.unlockChord) { [weak self] in
                self?.requestAuthenticationUnlock()
            }

            await setState(.locked)
        } catch {
            logger.error("Lock failed: \(error.localizedDescription, privacy: .public)")
            await inputBlocker.stop()
            powerManager.releaseAll()
            await MainActor.run {
                overlayManager.hide()
            }
            await setState(.failed)
        }
    }

    func authenticateAndUnlock() async {
        guard state == .locked, !authenticationInFlight else {
            return
        }
        authenticationInFlight = true
        await setState(.unlocking)

        let result = await authenticator.authenticate(reason: "Unlock Sentinel")
        authenticationInFlight = false

        switch result {
        case .success:
            await releaseLockResources()
            await setState(.unlocked)
        case let .failure(error):
            logger.warning("Unlock authentication failed: \(error.localizedDescription, privacy: .public)")
            await setState(.locked)
        }
    }

    func forceUnlockOnQuit() async {
        await releaseLockResources()
        await setState(.unlocked)
    }

    private func releaseLockResources() async {
        await inputBlocker.stop()
        powerManager.releaseAll()
        await MainActor.run {
            overlayManager.hide()
        }
    }

    private func setState(_ nextState: LockState) async {
        state = nextState
        let callback = stateDidChange
        await callback(nextState)
    }

    private nonisolated func requestLock() {
        Task {
            await lock()
        }
    }

    nonisolated func requestAuthenticationUnlock() {
        Task {
            await authenticateAndUnlock()
        }
    }
}
