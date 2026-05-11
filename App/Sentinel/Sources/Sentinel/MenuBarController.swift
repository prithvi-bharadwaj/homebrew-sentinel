import AppKit
import Combine
import SentinelCore

@MainActor
final class MenuBarController: NSObject {
    var onLock: (() -> Void)?

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var cancellables: Set<AnyCancellable> = []
    private var currentState: LockState = .unlocked

    init(settingsStore: SettingsStore) {
        super.init()
        configureStatusItem()
        configureMenu()

        settingsStore.$settings
            .map(\.showMenuBarIcon)
            .removeDuplicates()
            .sink { [weak self] isVisible in
                self?.statusItem.isVisible = isVisible
            }
            .store(in: &cancellables)
    }

    func update(state: LockState) {
        guard state != currentState else {
            return
        }
        currentState = state
        updateIcon(animated: true)
    }

    private func configureStatusItem() {
        statusItem.button?.imagePosition = .imageOnly
        statusItem.button?.toolTip = "Sentinel"
        updateIcon(animated: false)
    }

    private func configureMenu() {
        let menu = NSMenu()

        let lockItem = NSMenuItem(title: "Lock Now", action: #selector(lockNow), keyEquivalent: "L")
        lockItem.keyEquivalentModifierMask = [.command, .shift]
        lockItem.target = self
        menu.addItem(lockItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.keyEquivalentModifierMask = [.command]
        settingsItem.target = self
        menu.addItem(settingsItem)

        let aboutItem = NSMenuItem(title: "About Sentinel", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Sentinel", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func updateIcon(animated: Bool) {
        let imageName: String
        switch currentState {
        case .locked, .locking, .unlocking:
            imageName = "lock.fill"
        case .unlocked, .failed:
            imageName = "lock.open"
        }

        let applyImage = {
            self.statusItem.button?.image = NSImage(
                systemSymbolName: imageName,
                accessibilityDescription: self.currentState == .locked ? "Sentinel locked" : "Sentinel unlocked"
            )
        }

        guard animated, let button = statusItem.button else {
            applyImage()
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.12
            button.animator().alphaValue = 0
        } completionHandler: {
            applyImage()
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.16
                button.animator().alphaValue = 1
            }
        }
    }

    @objc private func lockNow() {
        onLock?()
    }

    @objc private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: "Sentinel",
            .applicationVersion: "0.1.1",
            .credits: NSAttributedString(string: "Free and open-source input locking for macOS.")
        ])
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
