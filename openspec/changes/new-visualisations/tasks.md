## 1. Audio Engine Extensions

- [ ] 1.1 Define `VisualizerStyle` enum with cases for `spectrumBars`, `oscilloscope`, `frequencyVortex`, and `metalParticles`
- [ ] 1.2 Add `@Published var currentStyle: VisualizerStyle` to `AudioEngineManager`
- [ ] 1.3 Add `@Published var rawSamples: [Float]` of 512 elements to `AudioEngineManager`
- [ ] 1.4 Implement `nextStyle()` and `previousStyle()` helper methods in `AudioEngineManager`
- [ ] 1.5 Update `processAudioBuffer(_:)` to extract and downsample time-domain PCM float buffer samples into `rawSamples`

## 2. New Renderer Implementations

- [ ] 2.1 Create `OscilloscopeVisualizer.swift` utilizing raw PCM data and rendering a continuous neon-glowing wave
- [ ] 2.2 Create `FrequencyVortexVisualizer.swift` using `Canvas` and `TimelineView(.animation)` to render radial, rotating frequency bands
- [ ] 2.3 Create `Shaders.metal` containing MSL (Metal Shading Language) vertex and fragment shaders for additive-blended particle rendering
- [ ] 2.4 Create `MetalParticleVisualizer.swift` implementing `NSViewRepresentable` to host `MTKView`, compile the render pipeline state, and run particle updates in the drawing loop

## 3. UI & Menu Shell Integration

- [ ] 3.1 Update `ActiveVisualizerContainer` in `VisualizerView.swift` to dynamically mount the selected visualizer style
- [ ] 3.2 Add Left and Right arrow key interception to the keyboard local event monitor in `VisualizerView.swift` and suppress default alert beeps by returning nil
- [ ] 3.3 Add the "Visualisation" `CommandMenu` in `VisualizerApp.swift` to support menu bar switches with checkmarks

## 4. Verification & Testing

- [ ] 4.1 Compile the project with `xcodebuild` to ensure zero compilation warnings or errors
- [ ] 4.2 Run the compiled application and verify visualizer transitions, keyboard arrow keys, and menu switches
