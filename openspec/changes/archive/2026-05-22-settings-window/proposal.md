## Why

Currently, all configuration toggles (such as switching capture sources and selecting specific physical microphone inputs) are managed through system menu bar items. To preserve a distraction-free, 100% clean visualizer canvas on the primary window while preparing the application for future expansions (dynamic custom shaders and AI generation integration), we need a dedicated native settings panel.

This change introduces a native, secondary utility Settings window to manage configurations, keeping the main interface completely free of overlays or configuration HUD controls.

## What Changes

- **Auxiliary Config Window**: A native secondary utility window (`SettingsView`/`NSWindow`) to configure application parameters.
- **Audio Capture Selector Duplication**: Retain the active audio input source toggle (Microphone vs. System Audio) and physical input device selector list in the system menu bar, while also adding them as dual-controls inside the new settings panel, ensuring real-time state synchronization between both interfaces.
- **Window Triggers**: Registering standard macOS triggers to summon the settings panel: the standard `⌘,` (Command + Comma) keyboard shortcut and an application menu item.

## Capabilities

### New Capabilities
- `settings-shell`: Native secondary configuration window containing categorized options for Audio settings and the future custom shader library placeholder.

### Modified Capabilities
- `visualizer-core`: Update startup and menu requirements to support secondary window instantiation and control duplication.

## Impact

- **VisualizerApp**: Registered to handle the secondary settings window lifecycle using SwiftUI's `Window` scene.
- **AudioEngineManager**: Expand state bindings to support real-time audio capture updates driven by settings controls.
- **Controls/Interactions**: Map standard `⌘,` keyboard shortcut to open the settings window.
