# Manual Testing

Real `CGEventTap` input blocking requires Accessibility permission and must be tested on a physical Mac.

## Accessibility Gate

1. Remove Sentinel from System Settings -> Privacy & Security -> Accessibility if it is already present.
2. Launch Sentinel.
3. Choose Lock Now from the menu-bar item.
4. Verify the onboarding window appears and the System Settings button opens the Accessibility pane.
5. Enable Sentinel in Accessibility.
6. Verify Sentinel detects the change without relaunching and continues the lock attempt.

## Lock And Unlock

1. Lock from the menu-bar item or `Command-Shift-L`.
2. Verify keyboard, trackpad, mouse buttons, pointer movement, drags, and scroll events do not reach foreground apps.
3. Press `Command-Shift-U`.
4. Verify Touch ID or password authentication appears.
5. Cancel authentication and confirm the Mac remains locked.
6. Authenticate successfully and confirm input works again.

## Displays

1. Lock with one display connected.
2. Connect a second display and verify an overlay appears on it.
3. Disconnect the display and verify the old overlay window is removed.

## Power

1. Lock Sentinel.
2. Leave the Mac idle longer than the normal display sleep delay.
3. Verify the display remains awake.
4. Unlock and verify normal power behavior resumes.
