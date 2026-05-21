## 1. State Persistence and Initialization Update

- [ ] 1.1 Load and save the selected `captureSource` in `AudioEngineManager.swift` using `UserDefaults` (key: `"selectedCaptureSource"`)
- [ ] 1.2 Default the `captureSource` to `.systemAudio` if no persisted value exists in `UserDefaults`
- [ ] 1.3 Update `switchCaptureSource(_:)` to persist the selected source to `UserDefaults`
- [ ] 1.4 Update `selectInputDevice(_:)` to persist `.microphone` to `UserDefaults` when a physical input device is explicitly selected

## 2. On-Demand AVAudioEngine and Teardown

- [ ] 2.1 Convert `audioEngine` from a `private let` constant to a `private var` optional `AVAudioEngine?` in `AudioEngineManager.swift`
- [ ] 2.2 Update `configureInputDevice(_:)` to safely unwrap and use `audioEngine`
- [ ] 2.3 Update `startMicrophoneStream()` to instantiate `audioEngine = AVAudioEngine()` before configuring and installing tap
- [ ] 2.4 Update `stopMicrophoneStream()` to safely stop the engine, remove tap, and set `audioEngine = nil`

## 3. Verification

- [ ] 3.1 Build the application and ensure zero compiler errors
- [ ] 3.2 Verify that the app launches in `System Audio` mode and doesn't trigger microphone indicator
- [ ] 3.3 Verify that switching to `Microphone` works perfectly and switches back to `System Audio` cleanly, releasing resources
- [ ] 3.4 Verify that the selected source state is preserved across application launches
