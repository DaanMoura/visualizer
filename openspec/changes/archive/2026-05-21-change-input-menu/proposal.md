## Why

The app currently exposes routing diagnostics in the visualizer surface, which conflicts with the goal of keeping the window focused only on the visualization. Users also need a native way to select audio inputs such as BlackHole without relying on system-wide default input changes.

## What Changes

- Remove all in-window HUD and diagnostics overlay elements from the visualizer experience.
- Add a native macOS menu bar menu for selecting the active audio input device.
- Support loopback-style devices such as BlackHole as selectable inputs when they are available to the system.
- Keep the visualizer window distraction-free, with only the rendered visualizer visible during normal operation.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `visualizer-core`: The main visualizer surface must no longer show HUD, diagnostics, or routing controls during normal visualization.
- `audio-capture-fft`: Audio capture must support selecting a specific input device from the macOS menu bar and reconfiguring capture without restarting the app.

## Impact

- Affects SwiftUI app/menu command structure, visualizer view composition, and audio engine device-selection behavior.
- Requires querying available Core Audio input devices using native Apple APIs and rebuilding the `AVAudioEngine` input path when selection changes.
- No new external dependencies.
