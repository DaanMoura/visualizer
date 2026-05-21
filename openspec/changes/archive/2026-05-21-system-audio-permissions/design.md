## Context

On macOS Tahoe (and Sonoma/Sequoia), Apple separated Screen Recording and System Audio Recording into more granular user options in System Settings. Users can grant an app "System Audio Recording Only" without enabling full "Screen Recording" (video). 
Currently, the Sound Visualizer uses `CGPreflightScreenCaptureAccess()` to check permission. However, `CGPreflightScreenCaptureAccess()` only checks for full Screen Recording permission and returns `false` if only "System Audio Recording Only" is enabled. This gets the app stuck on the permission warning screen even if ScreenCaptureKit would successfully stream audio.

## Goals / Non-Goals

**Goals:**
- Add required `NSAudioCaptureUsageDescription` and `NSScreenCaptureUsageDescription` privacy strings to the app's bundle.
- Add an asynchronous preflight fallback using `SCShareableContent` to detect when either full Screen Recording or "System Audio Recording Only" permission is granted.
- Ensure the app transitions out of the permission prompt view and begins streaming system audio once permissions are active.

**Non-Goals:**
- Recording, encoding, or streaming system video.
- Using virtual audio drivers or driver installations.

## Decisions

### 1. Asynchronous Fallback Preflight Check
When `CGPreflightScreenCaptureAccess()` returns `false`, the app will spawn a swift concurrency `Task` to attempt a call to `SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)`.
* **Rationale:** If the user has granted "System Audio Recording Only" permission, the ScreenCaptureKit system will allow `SCShareableContent` to execute successfully, while `CGPreflightScreenCaptureAccess()` will continue to report `false`. 
* **Alternatives:** Attempting to start the stream directly and catching the error works, but using `SCShareableContent` acts as a much cleaner preflight check because it does not attempt to allocate stream capture resources or spin up background capture queues.

### 2. Privacy Usage Description Declarations
We will declare both `NSAudioCaptureUsageDescription` and `NSScreenCaptureUsageDescription` in `Info.plist`.
* **Rationale:** Apple requires `NSAudioCaptureUsageDescription` for apps that use system-wide audio tapping or Core Audio taps on modern macOS versions. Declaring both keys ensures that whatever path macOS uses to prompt the user (Screen Recording or System Audio Recording Only), a clean user-facing description is displayed and the app does not crash.

## Risks / Trade-offs

- **Risk:** The `SCShareableContent` preflight check is asynchronous, which means the permission state might not be known immediately at synchronous initialization.
- **Mitigation:** We will execute this check inside a `Task` and dispatch updates to the published `@Published var screenCapturePermissionState` property on the `MainActor` (`DispatchQueue.main.async`). The SwiftUI view will automatically observe this state, and if the state transitions to `.granted`, the stream capture will immediately start.
