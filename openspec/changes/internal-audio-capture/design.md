## Context

The Sound Visualizer currently processes and visualizes audio captured from input-capable hardware or virtual loopback devices via `AVAudioEngine`. Virtual loopback drivers like BlackHole require manual installation and audio routing setup, which is inconvenient for end users. 

Apple's `ScreenCaptureKit` framework (macOS 13.0+) provides modern, high-performance, and driverless access to system-wide speaker output. This document details the design for integrating ScreenCaptureKit into the Sound Visualizer's audio pipeline as a first-class, selectable capture source.

## Goals / Non-Goals

**Goals:**
- Natively capture macOS system audio without third-party virtual audio drivers (like BlackHole).
- Seamlessly route the captured system audio PCM data to the existing `FFTProcessor` for visualization.
- Implement a user-facing toggle in the app's menu bar commands to switch between "Microphone/Input Devices" and "System Audio (Internal)".
- Provide elegant and robust permission checks and UX for both "Microphone" and "Screen Recording" permissions.

**Non-Goals:**
- Visualizing individual applications separately (capture is system-wide).
- Modifying the visualizer's rendering styles or adding equalizers.
- Recording or saving internal audio to disk.

## Decisions

### 1. Unified Pipeline Architecture in `AudioEngineManager`
We will extend `AudioEngineManager` to support a new state: `CaptureSource` (either `.microphone` or `.systemAudio`). 
- **Microphone Mode**: Standard `AVAudioEngine` capture path.
- **System Audio Mode**: Modern `SCStream` capture path.
- *Rationale*: Reuses the existing amplitude smoothing, peak decay logic, and downstream rendering layers without structural duplication.

### 2. High-Performance Zero-Copy CMSampleBuffer Conversion
In the ScreenCaptureKit `SCStreamOutput` delegate callback:
```swift
func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
    guard type == .audio, sampleBuffer.isValid else { return }
    // Convert to AVAudioPCMBuffer via zero-copy reference using withAudioBufferList
}
```
- *Rationale*: Avoids copying overhead, maintaining 60+ FPS visualization frame rate with negligible CPU footprint.

### 3. Screen Capture Permission Flow
Because ScreenCaptureKit requires "Screen Recording" permission to capture system audio, we will:
- Check permission via CoreGraphics `CGPreflightScreenCaptureAccess()`.
- Request permission via `CGRequestScreenCaptureAccess()` if needed.
- If not granted, update the app's UI state to show a specific "Screen Recording Permission Required" screen rather than launching the visualizer.
- *Rationale*: Provides a transparent onboarding flow to guide users through macOS Privacy & Security settings.

## Risks / Trade-offs

- **[Risk] Sandbox Constraints**: If App Sandbox is enabled, ScreenCaptureKit might fail to capture audio without the screen recording permission being actively granted by the user.
  - *Mitigation*: The app will proactively check `CGPreflightScreenCaptureAccess()` and guide the user to the System Settings pane using a dedicated permission onboarding view.
- **[Risk] No active audio stream**: ScreenCaptureKit requires at least one display to filter content, even if we are only capturing audio.
  - *Mitigation*: We will retrieve the primary display via `SCShareableContent` and configure the `SCStream` content filter using that display, with video capture explicitly disabled to minimize resource usage.
