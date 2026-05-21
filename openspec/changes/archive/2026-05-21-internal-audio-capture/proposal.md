## Why

Currently, the Sound Visualizer captures audio only from physical inputs (e.g., microphones) or virtual loopback devices (e.g., BlackHole). Setting up virtual audio drivers can be complex, error-prone, or restricted for many users. Leveraging macOS's native `ScreenCaptureKit` framework allows the application to capture system-wide internal audio natively and efficiently without requiring any external dependencies or virtual drivers.

## What Changes

- **Added** support for direct, driverless internal system audio capture using macOS `ScreenCaptureKit` (for macOS 13.0+).
- **Added** a source-selection mechanism in the app menus, allowing users to switch between "Microphone/Input Devices" and "System Audio (Internal)".
- **Added** permissions checking and custom onboarding/warning UI for "Screen Recording" permission, which is required by `ScreenCaptureKit`.
- **Modified** `AudioEngineManager` to toggle between `AVAudioEngine` input-node tapping (for hardware/loopback devices) and `ScreenCaptureKit` stream tapping (for internal system audio).
- **Modified** the permission warning interface to handle both microphone and screen recording permissions dynamically based on the selected capture mode.

## Capabilities

### New Capabilities

*None.*

### Modified Capabilities

- `audio-capture-fft`: Extend to support capturing system-wide internal audio natively using `ScreenCaptureKit` as an alternative to input device tapping, and handle its custom sample buffer format.
- `visualizer-core`: Update permission checking and warning workflows to include Screen Recording permissions when the system audio source is selected.

## Impact

- **Affected Code**: `AudioEngineManager.swift`, `VisualizerApp.swift`, `PermissionWarningView.swift`, `VisualizerView.swift`.
- **APIs**: ScreenCaptureKit (`SCStream`, `SCStreamConfiguration`, `SCContentFilter`), CoreGraphics permission check (`CGPreflightScreenCaptureAccess`).
- **Dependencies**: Uses native macOS 13.0+ ScreenCaptureKit; no third-party dependencies introduced.
