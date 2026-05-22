## Context

The macOS Sound Visualizer features a clean, zero-HUD main canvas. To let the user configure the application without introducing in-window overlays, we need to create a dedicated Settings window. 

This change covers the structural scaffolding of the utility Settings window and the migration of audio configuration controls (pickers for inputs and capture sources) to the settings window pane.

## Goals / Non-Goals

**Goals:**
- **Separate Config Shell**: A clean, native auxiliary window to configure audio inputs and persist LLM API credentials.
- **HUD-Free Main Window**: Maintain a distraction-free main window canvas, ensuring that selecting devices or configuring keys is entirely separated into the utility panel.
- **Persistent Key and Option Storage**: Securely store selected inputs, OpenRouter API keys, and local server URL fields using macOS `UserDefaults` (`@AppStorage` bindings).

**Non-Goals:**
- **Custom Shader Compilation & Editing (Phase 2)**: Dynamic compile pipelines, MSL editor, and canvas shader hot-reloads are out of scope for this change. The "Shader Library" tab in this phase will contain a simple, clean placeholder explaining the feature.
- **AI Network Integrations (Phase 3)**: API clients, models connection checks, and prompt triggers are out of scope.

## Decisions

### 1. Auxiliary Window Lifecycle via SwiftUI Window Scene API
- **Decision**: Declare a secondary `Window` scene in `VisualizerApp.swift` using `Window("Settings", id: "settings")` (available in macOS 13+).
- **Rationale**: Standard macOS practice, leveraging SwiftUI's native multi-window system. Opening is managed elegantly using:
  ```swift
  @Environment(\.openWindow) private var openWindow
  openWindow(id: "settings")
  ```
- **Triggers**: Linked natively to the standard `⌘,` keyboard shortcut and the "Settings..." command button in the application menu.
- **Behavior**: Because the window scene uses a static ID (`"settings"`), macOS guarantees that subsequent triggers will bring the existing Settings window to the foreground instead of spawning redundant copies.

### 2. Dual Audio Control Panels
- **Decision**: Retain the audio input source toggle and input device picker in the system menu bar, while also adding matching selectors in the dedicated 'Audio' settings tab of the Settings window.
- **Rationale**: Provides the best of both worlds: quick access to audio inputs from the global application menu bar, and a dedicated native settings panel for deeper configuration. Both panels bind directly to the shared `AudioEngineManager` instance, keeping state perfectly synced in real-time.

### 3. API Credentials Layout
- **Decision**: Implement text fields for OpenRouter API keys and Local Llama server endpoints bound directly to `UserDefaults` using SwiftUI's `@AppStorage`.
- **Rationale**: Provides instant state synchronization, standard visual security, and ensures Phase 3 has a clean foundation to read keys immediately.

### 4. Native Sidebar Layout & Tahoe Platform HIG
- **Decision**: Structure the Settings interface using a native SwiftUI `NavigationSplitView` (vertical sidebar on the left, scrollable content form on the right) and employ default platform styling for all controls (`Picker`, `TextField`, `Form`, `Section`, and `Toggle`).
- **Rationale**: Aligns perfectly with standard modern macOS System Settings (Sequoia/Tahoe HIG). Utilizing standard platform views ensures automatic dark/light mode compatibility, native focus indicators, robust keyboard accessibility, and standard window scaling.

## Risks / Trade-offs

- **[Risk] Audio stream stuttering during input swaps in the settings pane**
  - *Mitigation*: Trigger audio tap re-initialization asynchronously on a background queue when an input device or capture source is switched, ensuring the main thread and UI transitions remain responsive.
