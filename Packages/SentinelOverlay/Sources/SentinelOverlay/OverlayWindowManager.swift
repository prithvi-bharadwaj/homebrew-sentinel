import AppKit
import OSLog
import SentinelCore
import SwiftUI

/// Manages one full-screen lock overlay window per display.
@MainActor
public final class OverlayWindowManager {
    private var windows: [NSWindow] = []
    private var configuration: OverlayConfiguration?
    private let notificationCenter: NotificationCenter
    private let logger = Logger(subsystem: "org.localhost.sentinel", category: "overlay")

    /// Creates an overlay window manager.
    public init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        notificationCenter.addObserver(
            self,
            selector: #selector(screenParametersDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    /// Shows lock overlays on every current display.
    public func show(configuration: OverlayConfiguration) {
        self.configuration = configuration
        rebuildWindows()
    }

    /// Hides and releases all overlay windows.
    public func hide() {
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()
        configuration = nil
    }

    private func rebuildIfNeeded() {
        guard configuration != nil else {
            return
        }
        rebuildWindows()
    }

    @objc private func screenParametersDidChange(_ notification: Notification) {
        rebuildIfNeeded()
    }

    private func rebuildWindows() {
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()

        guard let configuration else {
            return
        }

        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false,
                screen: screen
            )
            window.level = .screenSaver
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = false
            window.contentView = NSHostingView(
                rootView: LockOverlayView(configuration: configuration)
            )
            window.orderFrontRegardless()
            windows.append(window)
        }

        logger.info("Rebuilt \(self.windows.count) overlay windows")
    }
}
