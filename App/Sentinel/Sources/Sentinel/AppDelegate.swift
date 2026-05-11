import AppKit
import KeyboardShortcuts
import SentinelAuth
import SentinelCore
import SentinelInput
import SentinelOverlay
import SentinelPower

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    let settingsStore = SettingsStore()

    private var menuBarController: MenuBarController?
    private var lockController: LockController?
    private let overlayManager = OverlayWindowManager()
    private let onboardingController = AccessibilityOnboardingController()
    private var currentLockState: LockState = .unlocked

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let menuBarController = MenuBarController(settingsStore: settingsStore)
        let lockController = LockController(
            settingsStore: settingsStore,
            overlayManager: overlayManager,
            onboardingController: onboardingController,
            inputBlocker: InputBlocker(),
            authenticator: BiometricAuthenticator(),
            powerManager: PowerAssertionManager(),
            stateDidChange: { [weak self, weak menuBarController] state in
                self?.currentLockState = state
                menuBarController?.update(state: state)
            }
        )

        menuBarController.onLock = {
            Task {
                await lockController.lock()
            }
        }

        KeyboardShortcuts.onKeyUp(for: .lockSentinel) {
            Task {
                await lockController.lock()
            }
        }

        self.menuBarController = menuBarController
        self.lockController = lockController

        if CommandLine.arguments.contains("--open-settings") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.openSettingsWindow()
            }
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        switch currentLockState {
        case .unlocked, .failed:
            return .terminateNow
        case .locked, .locking, .unlocking:
            lockController?.requestAuthenticationUnlock()
            return .terminateCancel
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        Task {
            await lockController?.forceUnlockOnQuit()
        }
    }

    func openSettingsWindow() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension KeyboardShortcuts.Name {
    static let lockSentinel = Self("lockSentinel", default: .init(.l, modifiers: [.command, .shift]))
}
