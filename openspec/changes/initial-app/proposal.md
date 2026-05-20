## Why

To bootstrap the Sound Visualizer project, we need an initial, fully-functional macOS application structure that captures audio input, processes it using real-time Fast Fourier Transform (FFT), and renders a single, elegant audio visualization. This establishes the codebase architecture, sets up project scaffolding, and acts as a foundation for subsequent styles.

## What Changes

- Create a Swift/SwiftUI macOS application skeleton that compiles and runs out-of-the-box.
- Implement an `AudioEngine` using `AVFoundation` / `AVAudioEngine` to tap the active system audio input (supporting physical microphones or virtual loopback devices like BlackHole) and request permissions.
- Implement an `FFTProcessor` using the `Accelerate` framework (`vDSP`) to convert incoming PCM audio buffers to frequency domain bins.
- Implement the "Spectrum Bars" visualizer style using SwiftUI Canvas for smooth, low-latency, real-time rendering.
- Set up a clean, distraction-free macOS window that supports resizing and basic native fullscreen toggling.

## Capabilities

### New Capabilities
- `visualizer-core`: The base Swift/SwiftUI macOS application scaffolding, including window lifecycle, resizability, and user permission handling.
- `audio-capture-fft`: Audio buffer capture via native `AVAudioEngine` from the active system input (mic/virtual loopback) and FFT frequency analysis via `Accelerate` / `vDSP`. Uses a fixed 2048-sample Hanning-windowed DFT plan (initialised once at startup) to avoid `vDSP_DFT_zop_CreateSetup` failures caused by non-conforming hardware buffer lengths (e.g. 4410 frames at 44.1 kHz). Amplitude normalised across a `-90 dB` to `-10 dB` range to cover real-world microphone and loopback signal levels.
- `spectrum-bars-style`: Real-time rendering of a retro-modern "Spectrum Bars" visualiser using a native SwiftUI `HStack` + `ForEach` of `SpectrumBar` views. Uses SwiftUI's reactive system (not `Canvas`) to ensure bars re-render on every `@Published` amplitude update, with neon gradients, glow layers, floating peak indicators, and smooth `.animation` transitions.

### Modified Capabilities
<!-- None -->

## Impact

- **New Xcode Project**: Creation of `Visualizer.xcodeproj` or equivalent package layout under `/Users/danielmoura/projects/visualizer/Visualizer`.
- **Target OS**: macOS 13+ (Ventura or later).
- **Core APIs**: `AVFoundation` (`AVAudioEngine`), `Accelerate` (`vDSP`), SwiftUI `Canvas`.
- **No External Dependencies**: 100% native Apple frameworks as per `AGENTS.md`. Supporting virtual loopback is handled entirely via standard macOS audio settings and requires no dynamic third-party library linkage.
