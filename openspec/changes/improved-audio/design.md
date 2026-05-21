## Context

When the Sound Visualizer starts or runs, it captures audio to render real-time visualizations. In previous versions, the default capture source was the Microphone, and `AVAudioEngine` was immediately instantiated and held in memory. Accessing the lazy property `AVAudioEngine.inputNode` triggers device acquisition in macOS Core Audio. 

For Bluetooth headsets (e.g., AirPods), this microphone session triggers a transition from high-quality stereo playback (A2DP profile) to low-quality mono communication mode (HFP/SCO profile) with high latency and echo cancellation. By making the driverless `System Audio (Internal)` capture source the default at launch and only instantiating `AVAudioEngine` when the Microphone source is actively selected, we can preserve pristine system-wide audio quality.

## Goals / Non-Goals

**Goals:**
* Prevent degradation of Bluetooth audio output quality by defaulting the app to `System Audio` mode.
* Only instantiate `AVAudioEngine` and tap the physical microphone on-demand when `.microphone` is explicitly selected.
* Fully release and deallocate `AVAudioEngine` resources when switching away from the Microphone source or when stopping capture.
* Persist the user's selected `CaptureSource` in `UserDefaults` across application restarts.

**Non-Goals:**
* Add third-party driver installations or custom audio loopbacks.
* Support concurrent capture of both System Audio and physical Microphone inputs.

## Decisions

### 1. On-Demand Instantiation of `AVAudioEngine`
We will replace the stored constant `private let audioEngine = AVAudioEngine()` with a nullable variable `private var audioEngine: AVAudioEngine?`.
* **Rationale:** Swift's `AVAudioEngine` automatically requests hardware input node references lazily. Once referenced or prepared, releasing the hardware session is unreliable unless the engine itself is completely deallocated. By using a nullable variable and setting it to `nil` when inactive, we guarantee complete memory and driver-level teardown.
* **Alternative Considered:** Keeping a single persistent `AVAudioEngine` and calling `stop()` on it. This is insufficient because macOS keeps the input tap and device context open even after `stop()` is called if `inputNode` was accessed.

### 2. Startup Capture Source Strategy
The application will check `UserDefaults` for a persisted `CaptureSource`. If none exists, it will default to `System Audio` (.systemAudio) instead of `Microphone` (.microphone).
* **Rationale:** High-quality output is preserved right from application start because no microphone permissions or device nodes are touched during default startup.
* **Alternative Considered:** Not starting any capture on launch. This violates the visualizer's goal of being a simple, instant-on, distraction-free visualizer.

### 3. Clear State Persistence
State persistence for `captureSource` will be stored in `UserDefaults` using a key `"selectedCaptureSource"`.
* **Rationale:** Extremely simple, fast, and does not require complex database layers or external dependencies.

## Risks / Trade-offs

* **[Risk]** Instantiating `AVAudioEngine` dynamically when switching to `.microphone` might introduce a slight lag.
  * *Mitigation:* `AVAudioEngine` initialization is extremely fast (~milliseconds). Tapping a device dynamically takes minimal overhead and will be performed asynchronously if needed.
* **[Risk]** If Screen Capture permissions are denied, defaulting to `System Audio` could result in a blank screen.
  * *Mitigation:* The app already presents a beautiful `PermissionWarningView` when permissions are denied or undetermined, guiding the user to authorize screen capture.

## Migration Plan

No data migration is required. `UserDefaults` will be queried safely. If the key is not present, we default gracefully to `.systemAudio`.

## Open Questions

None.
