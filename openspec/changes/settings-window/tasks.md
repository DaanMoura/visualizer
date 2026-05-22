## 1. Settings Window Scaffolding

- [ ] 1.1 Declare the secondarySettings window scene in `VisualizerApp.swift` using `Window("Settings", id: "settings")`
- [ ] 1.2 Create the base `SettingsView.swift` containing a modular, modern tab bar with panels for 'Audio', 'API Credentials', and 'Shader Library'
- [ ] 1.3 Map standard `⌘,` (Command + Comma) keyboard triggers and application menu command items to open the Settings window natively via SwiftUI's `openWindow` environment action

## 2. Control Integration & Persistence

- [ ] 2.1 Add audio capture source and input device pickers to the 'Audio' tab of the new Settings panel, keeping the existing menu bar controls fully functional
- [ ] 2.2 Implement `@AppStorage` persistent text inputs for OpenRouter API key, model selection, and local Llama endpoints in the 'API Credentials' tab
- [ ] 2.3 Create an aesthetic placeholder layout in the 'Shader Library' tab describing the custom dynamic visualization and sandboxed MSL shaders slated for Phase 2

## 3. Verification & Testing

- [ ] 3.1 Compile the visualizer using CLI or Xcode and verify zero compiler warnings or build failures
- [ ] 3.2 Verify settings window opening, closing, and automatic key focus recycling (no redundant window duplication)
- [ ] 3.3 Verify that changing audio inputs/capture sources in the settings window immediately updates the selections in the system menu bar, and vice versa (perfect real-time synchronization)
