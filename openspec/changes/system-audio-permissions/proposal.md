## Why

On macOS Tahoe (v16.0 / internal 26.3.1) and newer, a granular "System Audio Recording Only" permission is available. When a user grants this specific permission, `CGPreflightScreenCaptureAccess()` returns `false` because it only checks for full screen video recording. This causes the application to get stuck on the screen asking for "Screen & System Audio Recording" permissions even though the system audio stream can be successfully initialized. 

Additionally, standardizing system-wide audio capture with the proper `NSAudioCaptureUsageDescription` key allows the app to be properly grouped under System Settings alongside other driverless audio utilities like the "Granola" app.

## What Changes

- Add `NSAudioCaptureUsageDescription` and `NSScreenCaptureUsageDescription` keys to `Info.plist` to declare system audio recording capabilities and custom permission prompt messages.
- Implement an asynchronous preflight fallback check in `checkScreenCapturePermission()` using `SCShareableContent` to detect if the user has granted "System Audio Recording Only" access when `CGPreflightScreenCaptureAccess()` returns `false`.
- Ensure the app transitions out of the permission prompt view into the visualization surface when either full Screen Recording OR "System Audio Recording Only" permission is granted.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `audio-capture-fft`: Updates the preflight permission requirements to support the more granular "System Audio Recording Only" permission and avoid getting stuck on the permission view.

## Impact

- Affected Code: `Info.plist`, `AudioEngineManager.swift`, `PermissionWarningView.swift`.
- Entitlements: Requires correct code-signing and bundle configuration (already set).
