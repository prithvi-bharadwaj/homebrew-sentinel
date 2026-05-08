import SwiftUI

@main
struct SentinelApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsRootView(settingsStore: appDelegate.settingsStore)
        }
    }
}
