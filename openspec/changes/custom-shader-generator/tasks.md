## 1. Dynamic Rendering Scaffolding

- [ ] 1.1 Add the `.dynamicShader` style case to the `VisualizerStyle` enum
- [ ] 1.2 Create `DynamicMetalVisualizer.swift` hosting an `MTKView` conforming to `NSViewRepresentable`
- [ ] 1.3 Integrate the dynamic rendering surface into `ActiveVisualizerContainer` in `VisualizerView.swift`

## 2. Dynamic Compiler & Audio Pipeline

- [ ] 2.1 Implement background-thread shader compilation using `MTLDevice.makeLibrary(source:options:completionHandler:)`
- [ ] 2.2 Define standard `AudioDataUniforms` data structures in Swift matching the MSL shader uniforms structure
- [ ] 2.3 Bind raw time-domain samples, FFT frequency bins, time, and viewport dimensions to buffer index 0 on every render frame

## 3. Shader Library UI & Console Panel

- [ ] 3.1 Implement custom shader storage state in `AudioEngineManager` (adding, editing, listing, and persisting user shaders)
- [ ] 3.2 Replace the Shader Library placeholder pane in `SettingsView.swift` with a functional code editor and "Run / Activate" trigger
- [ ] 3.3 Add a compilation console output window at the bottom of the 'Shader Library' settings pane to report warnings or compile syntax errors

## 4. Verification & Testing

- [ ] 4.1 Build the application successfully with zero compiler warnings or errors
- [ ] 4.2 Verify dynamic compile hot-reloading by loading a valid custom shader string
- [ ] 4.3 Verify compilation failure isolation by loading an invalid shader, checking that syntax errors are displayed in the Settings console without crashing the rendering process
