## 1. Project Setup & Scaffolding

- [x] 1.1 Create the macOS Swift Xcode project structure in `/Visualizer`
- [x] 1.2 Implement the SwiftUI Application Entry Point (`VisualizerApp.swift`)
- [x] 1.3 Implement the Main Window styling (resizable, titlebar hidden, custom minimum size)
- [x] 1.4 Add Info.plist entries for `NSMicrophoneUsageDescription` to enable audio capture permissions

## 2. Audio Capture & Permissions

- [ ] 2.1 Create an `AudioEngineManager` to check, request, and observe macOS microphone permissions
- [ ] 2.2 Implement permission warning view presented when permission is denied or restricted
- [ ] 2.3 Set up `AVAudioEngine` and install tap on `AVAudioInputNode` to capture PCM audio buffers
- [ ] 2.4 Handle input node sample rate changes and route change notifications to dynamically re-initialize the audio tap

## 3. FFT Analysis & Signal Processing

- [ ] 3.1 Implement the `FFTProcessor` class utilizing the Apple `Accelerate` framework (`vDSP`)
- [ ] 3.2 Implement a buffer processing callback that computes magnitude spectrum from PCM buffers
- [ ] 3.3 Set up logarithmic frequency binning to group FFT results into distinct bands (e.g., 32 bins)
- [ ] 3.4 Implement smoothing / exponential decay filter on the calculated frequency bins to prevent jitter

## 4. Visualizer Rendering (Spectrum Bars)

- [ ] 4.1 Create `SpectrumBarsVisualizer` SwiftUI View using `Canvas` for hardware-accelerated rendering
- [ ] 4.2 Draw spectrum bars using vertical rounded rectangles filled with neon gradients (e.g., Cyan to Magenta)
- [ ] 4.3 Implement floating peak indicator dots that capture the highest level reached by each bar
- [ ] 4.4 Implement physics-based gravity decay logic for peak indicator dots (brief hold time followed by rapid descent)
- [ ] 4.5 Ensure layout math adapts dynamically to canvas bounding box changes (resizing/fullscreen)

## 5. Controls, Polish & Verification

- [ ] 5.1 Implement double-click gesture listener on the visualizer canvas to toggle native fullscreen mode
- [ ] 5.2 Add keyboard event listener to toggle native fullscreen mode using the 'F' key
- [ ] 5.3 Document the virtual audio loopback driver setup instructions (e.g., BlackHole) in the README
- [ ] 5.4 Verify building and running the complete visualizer application successfully on macOS
- [ ] 5.5 Validate permission workflow, layout adaptation, and smooth 60+ FPS rendering under load
