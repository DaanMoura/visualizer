## 1. Audio Device Model & Enumeration

- [x] 1.1 Add an input-device model to `AudioEngineManager` with stable `AudioObjectID`, display name, and selected-state support.
- [x] 1.2 Implement Core Audio enumeration for input-capable devices, including aggregate and loopback devices such as BlackHole.
- [x] 1.3 Publish the available input-device list and selected input device for SwiftUI menu rendering.
- [x] 1.4 Refresh input devices when `AVAudioEngineConfigurationChange` or Core Audio hardware changes occur.

## 2. Capture Reconfiguration

- [ ] 2.1 Add an `selectInputDevice(_:)` API that stores the chosen device and restarts capture when permissions allow.
- [ ] 2.2 Update audio stream startup to use the selected input device when available and fall back to the system default when needed.
- [ ] 2.3 Handle selected-device removal or invalid sample-rate states by falling back to the default input without crashing.
- [ ] 2.4 Preserve FFT/amplitude processing and peak decay behavior across input-device changes.

## 3. Native macOS Menu

- [ ] 3.1 Add a SwiftUI `Commands` menu in `VisualizerApp.swift` for audio input selection.
- [ ] 3.2 Render all published input devices as menu commands with a checkmark or selected indicator for the active input.
- [ ] 3.3 Add a menu refresh command or automatic refresh-on-open behavior using the existing published device list.
- [ ] 3.4 Ensure selecting BlackHole or another listed input reconfigures capture without restarting the app.

## 4. Visualizer Surface Cleanup

- [ ] 4.1 Remove the active-state HUD, live/offline indicator, diagnostics toggle, device label, RMS meter, and helper text from `ActiveVisualizerContainer`.
- [ ] 4.2 Keep the permission request and permission denied screens available before audio access is granted.
- [ ] 4.3 Ensure the active visualizer window renders only `SpectrumBarsVisualizer` while preserving double-click fullscreen support.
- [ ] 4.4 Keep the `F` keyboard shortcut behavior unchanged after removing the HUD.

## 5. Verification

- [ ] 5.1 Build the macOS app successfully in Xcode or via `xcodebuild`.
- [ ] 5.2 Verify the active window has no HUD or diagnostics overlay when permissions are granted.
- [ ] 5.3 Verify the menu lists the built-in microphone and BlackHole when BlackHole is installed.
- [ ] 5.4 Verify switching inputs updates visualizer response without restarting the app.
- [ ] 5.5 Verify disconnecting or removing a selected input falls back gracefully to the default input.
