## 1. Auxiliary Settings Window Scaffolding

- [ ] 1.1 Declare a secondary native Window scene in `VisualizerApp.swift` with window ID `settings`
- [ ] 1.2 Implement the core `SettingsView.swift` layout with tabs for 'Audio', 'API Credentials', and 'Shader Library'
- [ ] 1.3 Bind `⌘,` (Command + Comma) and application menu bar commands to trigger the settings window via SwiftUI's `openWindow` environment action

## 2. Settings Control & Credentials Persistence

- [ ] 2.1 Migrate audio capture source selectors and input device pickers from the system menu bar to the 'Audio' tab of `SettingsView.swift`
- [ ] 2.2 Add input fields and persistent storage (UserDefaults) for OpenRouter API key, model selection, and local Llama server connection endpoint in the 'API Credentials' tab

## 3. Shader Library Manager

- [ ] 3.1 Implement custom shader library state in `AudioEngineManager` supporting creating, editing, and listing user-defined shaders
- [ ] 3.2 Add a robust multiline text/code editor pane and a "Run / Activate" trigger in the 'Shader Library' tab of `SettingsView.swift`
- [ ] 3.3 Add a compilation console output window in the settings panel to display real-time warnings or compilation errors from the Metal compiler

## 4. Dynamic Metal Compilation Engine

- [ ] 4.1 Create `DynamicMetalVisualizer.swift` hosting an `MTKView` conforming to `NSViewRepresentable`
- [ ] 4.2 Define a unified `AudioDataUniforms` data blueprint in Swift matching the MSL shader uniforms structure
- [ ] 4.3 Implement non-blocking background shader compilation using `MTLDevice.makeLibrary(source:options:completionHandler:)`
- [ ] 4.4 Bind FFT frequency bins, time-domain raw PCM samples, viewport dimensions, and time coordinates to fragment buffer index 0 on every frame draw

## 5. System Integration & Verification

- [ ] 5.1 Add a `.dynamicShader` style case to the `VisualizerStyle` enum
- [ ] 5.2 Integrate the dynamic rendering surface into `ActiveVisualizerContainer`
- [ ] 5.3 Verify error capturing by loading an invalid shader string and ensuring compilation failures are reported in the settings console without crashing the app
