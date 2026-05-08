import AppKit
import KeyboardShortcuts
import OSLog
import SentinelCore
import ServiceManagement
import SwiftUI

struct SettingsRootView: View {
    @ObservedObject var settingsStore: SettingsStore
    private let logger = Logger(subsystem: "org.localhost.sentinel", category: "settings")

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            shortcutsTab
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            behaviorTab
                .tabItem {
                    Label("Behavior", systemImage: "lock.shield")
                }
        }
        .padding(20)
        .frame(width: 560, height: 360)
    }

    private var generalTab: some View {
        Form {
            Toggle("Launch at login", isOn: launchAtLoginBinding)
            Toggle("Show menu bar icon", isOn: binding(\.showMenuBarIcon))
        }
        .formStyle(.grouped)
    }

    private var shortcutsTab: some View {
        Form {
            KeyboardShortcuts.Recorder("Lock", name: .lockSentinel)
            LabeledContent("Unlock") {
                UnlockShortcutRecorder(
                    chord: Binding(
                        get: { settingsStore.settings.unlockChord },
                        set: { newChord in
                            settingsStore.update { settings in
                                settings.unlockChord = newChord
                            }
                        }
                    )
                )
            }
        }
        .formStyle(.grouped)
    }

    private var behaviorTab: some View {
        Form {
            Toggle("Prevent sleep when locked", isOn: binding(\.preventSleepWhenLocked))
            Toggle("Prevent sleep with lid closed", isOn: binding(\.preventSleepWithLidClosed))
            Toggle("Blur screen when locked", isOn: binding(\.blurScreenWhenLocked))
            Toggle("Show unlock button on overlay", isOn: binding(\.showUnlockButtonOnOverlay))
        }
        .formStyle(.grouped)
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.settings.launchAtLogin },
            set: { enabled in
                do {
                    if enabled {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                    settingsStore.update { settings in
                        settings.launchAtLogin = enabled
                    }
                } catch {
                    logger.warning("Launch at login update failed: \(error.localizedDescription, privacy: .public)")
                }
            }
        )
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<SentinelCore.Settings, Value>) -> Binding<Value> {
        Binding(
            get: { settingsStore.settings[keyPath: keyPath] },
            set: { newValue in
                settingsStore.update { settings in
                    settings[keyPath: keyPath] = newValue
                }
            }
        )
    }
}

private struct UnlockShortcutRecorder: View {
    @Binding var chord: UnlockChord
    @StateObject private var capture = ShortcutCapture()

    var body: some View {
        HStack(spacing: 10) {
            Text(chord.displayString)
                .font(.system(.body, design: .monospaced).weight(.medium))
                .frame(minWidth: 72, alignment: .leading)

            Button(capture.isRecording ? "Press Shortcut" : "Record") {
                capture.begin { newChord in
                    chord = newChord
                }
            }
            .disabled(capture.isRecording)

            Button("Reset") {
                chord = .default
            }
        }
    }
}

@MainActor
private final class ShortcutCapture: ObservableObject {
    @Published var isRecording = false
    private var monitor: Any?

    func begin(onCapture: @escaping (UnlockChord) -> Void) {
        stop()
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let modifiers = ModifierFlags(nsEventFlags: event.modifierFlags)
            guard !modifiers.isEmpty else {
                NSSound.beep()
                return nil
            }
            let chord = UnlockChord(keyCode: UInt16(event.keyCode), modifiers: modifiers)
            onCapture(chord)
            self?.stop()
            return nil
        }
    }

    func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
        isRecording = false
    }

    deinit {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

private extension ModifierFlags {
    init(nsEventFlags: NSEvent.ModifierFlags) {
        var flags: ModifierFlags = []
        if nsEventFlags.contains(.command) {
            flags.insert(.command)
        }
        if nsEventFlags.contains(.shift) {
            flags.insert(.shift)
        }
        if nsEventFlags.contains(.option) {
            flags.insert(.option)
        }
        if nsEventFlags.contains(.control) {
            flags.insert(.control)
        }
        self = flags
    }
}
