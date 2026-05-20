## 1. Project Setup & Scaffolding

- [x] 1.1 Create the macOS Swift Xcode project structure in `/Visualizer`
- [x] 1.2 Implement the SwiftUI Application Entry Point (`VisualizerApp.swift`)
- [x] 1.3 Implement the Main Window styling (resizable, titlebar hidden, custom minimum size)
- [x] 1.4 Add Info.plist entries for `NSMicrophoneUsageDescription` to enable audio capture permissions

## 2. Audio Capture & Permissions

- [x] 2.1 Create an `AudioEngineManager` to check, request, and observe macOS microphone permissions
- [x] 2.2 Implement permission warning view presented when permission is denied or restricted
- [x] 2.3 Set up `AVAudioEngine` and install tap on `AVAudioInputNode` to capture PCM audio buffers
- [x] 2.4 Handle input node sample rate changes and route change notifications to dynamically re-initialize the audio tap

## 3. FFT Analysis & Signal Processing

- [x] 3.1 Implement the `FFTProcessor` class utilizing the Apple `Accelerate` framework (`vDSP`)
- [x] 3.2 Implement a buffer processing callback that computes magnitude spectrum from PCM buffers
- [x] 3.3 Set up logarithmic frequency binning to group FFT results into distinct bands (e.g., 32 bins)
- [x] 3.4 Implement smoothing / exponential decay filter on the calculated frequency bins to prevent jitter

## 4. Visualizer Rendering (Spectrum Bars)

- [x] 4.1 Create `SpectrumBarsVisualizer` SwiftUI View using `Canvas` for hardware-accelerated rendering
- [x] 4.2 Draw spectrum bars using vertical rounded rectangles filled with neon gradients (e.g., Cyan to Magenta)
- [x] 4.3 Implement floating peak indicator dots that capture the highest level reached by each bar
- [x] 4.4 Implement physics-based gravity decay logic for peak indicator dots (brief hold time followed by rapid descent)
- [x] 4.5 Ensure layout math adapts dynamically to canvas bounding box changes (resizing/fullscreen)

## 5. Controls, Polish & Verification

- [x] 5.1 Implement double-click gesture listener on the visualizer canvas to toggle native fullscreen mode
- [x] 5.2 Add keyboard event listener to toggle native fullscreen mode using the 'F' key
- [x] 5.3 Document the virtual audio loopback driver setup instructions (e.g., BlackHole) in the README
- [x] 5.4 Verify building and running the complete visualizer application successfully on macOS
- [x] 5.5 Validate permission workflow, layout adaptation, and smooth 60+ FPS rendering under load

## 6. Amplitude Sensitivity Calibration & Diagnostics Overlay

- [x] 6.1 Redesign the frequency scaling formula in `FFTProcessor.swift` using standard engineering decibel mapping (`-65 dB` to `-15 dB`)
- [x] 6.2 Add active device name query and real-time RMS input volume calculation to `AudioEngineManager.swift`
- [x] 6.3 Implement a toggleable or subtle Diagnostics Overlay in `VisualizerView.swift` showing current device name and RMS audio level
- [x] 6.4 Validate sensitive spectrum bar responses using real Spotify digital music streams at low, medium, and high volumes
- [x] 6.5 Confirm that active devices and signal levels display correctly in the HUD for streamlined routing troubleshooting
- [x] 6.6 Migrate rendering physics and decay calculations from CVDisplayLink to direct audio tap callbacks to resolve the frozen spectrum bars bug

## 7. Post-Implementation Bug Fixes: Spectrum Bars Not Animating

- [x] 7.1 **[Bug] vDSP DFT setup failing silently for non-conforming buffer lengths**
  - Root cause: `AVAudioEngine` delivers buffers of **4410 frames** at 44100 Hz (one render slice = ~10 ms). `vDSP_DFT_zop_CreateSetup` requires N = `2^a × 3^b × 5^c`; 4410 = `2 × 3² × 5 × 7²` contains a factor of 7, so setup returned `nil` on every call. Every buffer was silently discarded, returning all-zero bins.
  - Fix: Initialise the DFT plan **once** in `FFTProcessor.init()` with a fixed `N = 2048` (`2^11` ✓). Each incoming buffer is copied into that fixed window (zero-padded or truncated as needed) before running the transform. This is the industry-standard approach for real-time audio visualisers.

- [x] 7.2 **[Bug] SwiftUI `Canvas` not re-rendering when `@EnvironmentObject` `@Published` values change**
  - Root cause: `Canvas { context, size in ... }` executes its draw closure outside SwiftUI's state-tracking graph. Accessing `@EnvironmentObject` properties inside the closure does **not** register a dependency, so the canvas never invalidates when `amplitudes` changes.
  - Fix: Replaced `Canvas`-based renderer with a native `HStack` + `ForEach` of `SpectrumBar` SwiftUI views. SwiftUI's reactive system correctly observes `@EnvironmentObject` changes and invalidates each bar view individually, driving smooth `.animation(.linear(duration:))` transitions on every amplitude update.
