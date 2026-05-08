import AppKit
import SwiftUI

@MainActor
final class AccessibilityOnboardingController {
    private var window: NSWindow?
    private var pollingTask: Task<Void, Never>?

    func present(onTrusted: @escaping @MainActor () -> Void) {
        showWindow()
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                if AccessibilityPermission.isTrusted() {
                    self?.dismiss()
                    onTrusted()
                    return
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    func dismiss() {
        pollingTask?.cancel()
        pollingTask = nil
        window?.orderOut(nil)
        window = nil
    }

    private func showWindow() {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let content = AccessibilityOnboardingView {
            AccessibilityPermission.openSystemSettings()
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 260),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Sentinel Accessibility"
        window.contentView = NSHostingView(rootView: content)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = window
    }
}

private struct AccessibilityOnboardingView: View {
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Accessibility Permission Required", systemImage: "hand.raised.fill")
                .font(.title2.weight(.semibold))

            Text("Sentinel needs Accessibility permission to block keyboard, mouse, and trackpad events while locked.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                onOpenSettings()
            } label: {
                Label("Open System Settings", systemImage: "gearshape")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Text("Sentinel will continue automatically after permission is enabled.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
