## Context

The visualizer currently includes a top HUD in `ActiveVisualizerContainer` with live/offline status, device name, RMS level, and helper text. That is useful for diagnostics but conflicts with the app's core scope: the window should show only the visualization during normal use.

Audio capture currently taps `AVAudioEngine.inputNode`, which follows the system default input. This makes loopback workflows dependent on changing macOS Sound settings. Users need to select BlackHole or another input from the app's native menu bar while keeping the visualizer window clean.

## Goals / Non-Goals

**Goals:**

- Remove all in-window HUD and diagnostics UI from the active visualizer state.
- Add a native macOS menu bar entry that lists available input devices and marks the current selection.
- Reconfigure audio capture when the selected device changes without requiring an app restart.
- Preserve microphone permission handling, fullscreen gestures/keyboard support, and the distraction-free visualizer window.

**Non-Goals:**

- No in-window input selector, sidebar, settings panel, equalizer, playlist, or audio routing dashboard.
- No external dependencies or third-party audio routing framework.
- No automatic installation or configuration of BlackHole.

## Decisions

1. Use SwiftUI `Commands` for the input selector.

   Rationale: `Commands` is the native SwiftUI mechanism for macOS menu bar items and keeps controls outside the visualizer surface. The menu can expose an "Audio Input" submenu with each available device as a selectable command.

   Alternative considered: An overlay or toolbar inside the window. Rejected because the requested experience is "only the visualizer visible."

2. Add native Core Audio input-device enumeration to `AudioEngineManager`.

   Rationale: `AVAudioEngine` alone does not provide a complete SwiftUI-friendly list of selectable hardware devices. Core Audio can query devices, names, input stream support, and device identifiers without dependencies.

   Alternative considered: Only using `AVCaptureDevice.devices(for: .audio)`. It is simpler, but Core Audio gives better control over aggregate and loopback devices commonly used for internal audio routing.

3. Store the selected input as an `AudioObjectID` with a display name.

   Rationale: The audio engine needs a stable identifier for menu selection and route-change recovery. The display name is for the native menu only.

   Alternative considered: Store only the device name. Rejected because names may not be unique and can change.

4. Rebuild the capture stream when selection changes.

   Rationale: Changing devices requires removing the existing tap, stopping the engine, setting the selected input where supported, and reinstalling the tap using the selected device's valid format. The visualizer should keep its state arrays but allow amplitudes to naturally respond to the new stream.

   Alternative considered: Let macOS default input changes drive all switching. Rejected because the requested feature is app-level selection from the menu bar.

## Risks / Trade-offs

- Core Audio device selection can differ across physical, aggregate, and loopback devices -> Mitigate by filtering to devices with input streams and falling back to the system default if the selected device disappears.
- `AVAudioEngine` input-device assignment is lower-level than default input capture -> Mitigate with a small, isolated device-selection API in `AudioEngineManager` and route-change tests against default mic and BlackHole.
- Menu state can become stale when devices are plugged in or removed -> Mitigate by refreshing device lists on audio configuration changes and when the menu command appears.
- Removing the HUD also removes visible troubleshooting data -> Mitigate by keeping device selection visible in the macOS menu while leaving the window clean.
