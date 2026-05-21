## 1. Core Integration & Capture Source State

- [x] 1.1 Add a `CaptureSource` enum representing `.microphone` and `.systemAudio` to `AudioEngineManager.swift`.
- [x] 1.2 Publish the current `CaptureSource` and implement a thread-safe `switchCaptureSource(_:)` method.
- [x] 1.3 Update stream startup and shutdown paths to handle switching between source types cleanly without crashing.

## 2. ScreenCaptureKit Audio Capture Path

- [x] 2.1 Retrieve the default display using `SCShareableContent` to configure `SCStream` (disabled video capture, enabled audio capture).
- [x] 2.2 Conform a helper or `AudioEngineManager` to `SCStreamOutput` and implement the `stream(_:didOutputSampleBuffer:of:)` callback.
- [x] 2.3 Add zero-copy conversion from `CMSampleBuffer` to `AVAudioPCMBuffer` using `withAudioBufferList` and route it to `processAudioBuffer`.
- [x] 2.4 Handle ScreenCaptureKit capture start, stop, and configuration lifecycle events safely.

## 3. Dynamic Permissions & Onboarding UI

- [x] 3.1 Implement a `CGPreflightScreenCaptureAccess` permission check helper in `AudioEngineManager`.
- [x] 3.2 Add a new published permission state for screen recording (undetermined, granted, denied).
- [x] 3.3 Update `PermissionWarningView.swift` to support displaying a "Screen Recording Permission" guide alongside the existing "Microphone Permission" guide.
- [x] 3.4 Update the permission validation branch in `VisualizerView.swift` to display the appropriate permission warning depending on the selected source.

## 4. UI Menu Source Selection

- [ ] 4.1 Update `VisualizerApp.swift` menus to include a new source picker segment ("Microphone" vs "System Audio").
- [ ] 4.2 Reflect the selected active source state dynamically in the menu bar with checked markers.
- [ ] 4.3 Ensure switching modes restarts capture paths instantly and updates the UI state smoothly.

## 5. Verification & Testing

- [ ] 5.1 Build the application and ensure zero compiler warnings.
- [ ] 5.2 Test "Microphone" mode capture with standard system microphone or virtual device (BlackHole) and verify FFT response.
- [ ] 5.3 Test "System Audio" mode capture with internal audio (e.g. playing audio in Safari/Music) and verify driverless FFT response.
- [ ] 5.4 Verify the permission error screens trigger correctly when disabling microphone or screen recording permission in macOS Settings.
