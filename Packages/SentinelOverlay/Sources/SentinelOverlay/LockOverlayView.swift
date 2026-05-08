import SwiftUI

/// SwiftUI content displayed by every lock overlay window.
public struct LockOverlayView: View {
    private let configuration: OverlayConfiguration
    private let onUnlock: () -> Void
    @State private var animateGradient = false

    /// Creates a lock overlay view.
    public init(configuration: OverlayConfiguration, onUnlock: @escaping () -> Void) {
        self.configuration = configuration
        self.onUnlock = onUnlock
    }

    /// The overlay body.
    public var body: some View {
        ZStack {
            if configuration.blurScreen {
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                    .ignoresSafeArea()
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.58),
                    Color.blue.opacity(animateGradient ? 0.34 : 0.18),
                    Color.mint.opacity(animateGradient ? 0.18 : 0.28)
                ],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animateGradient)

            VStack(spacing: 18) {
                Image(systemName: "touchid")
                    .font(.system(size: 68, weight: .regular))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)

                Text("Sentinel")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Place finger on Touch ID or press \(configuration.unlockChordDisplay)")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.82))

                if configuration.showUnlockButton {
                    Button("Unlock") {
                        onUnlock()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .keyboardShortcut(.defaultAction)
                    .accessibilityHint("Starts Touch ID or password authentication")
                }
            }
            .multilineTextAlignment(.center)
            .padding(32)
        }
        .onAppear {
            animateGradient = true
        }
    }
}
