## Why

When the Sound Visualizer application starts or captures audio, macOS defaults or accesses the microphone input node (`AVAudioEngine.inputNode`). This triggers the microphone capture session globally, forcing Bluetooth headsets (such as AirPods) to switch from high-quality stereo output (A2DP profile) to low-quality mono communication mode (HFP/SCO profile) with heavy echo cancellation. By ensuring that AVAudioEngine resources are only allocated when the microphone is actively selected, and by making the driverless System Audio capture source (via ScreenCaptureKit) the default, users can enjoy a pristine, high-fidelity audio visualization experience.

## What Changes

- Make the driverless `System Audio (Internal)` capture source the default option at launch to avoid triggering microphone access unnecessarily.
- Persist the selected `CaptureSource` across application launches using `UserDefaults`.
- Deallocate and reset `AVAudioEngine` resources completely when capturing from System Audio or when capture is stopped, causing macOS to release the microphone device and restore high-fidelity Bluetooth audio profiles immediately.
- Prevent accessing `audioEngine.inputNode` or initializing standard Core Audio device sessions during startup or when `System Audio` is selected.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `audio-capture-fft`: Switched the default startup source, added state persistence, and updated resource deallocation rules to prevent unintended microphone activation and audio quality degradation.

## Impact

- **Affected Code**: `AudioEngineManager.swift` (initialization, start/stop streams, permission preflighting, and capture source switching).
- **Dependencies**: No external dependencies are added. Built entirely on native macOS APIs.
