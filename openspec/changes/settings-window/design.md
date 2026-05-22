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

### 2. Audio Control Panel Migration
- **Decision**: Relocate the audio input source toggle and input device picker from the system menu bar to a dedicated 'Audio' settings tab.
- **Rationale**: Declutters the global application menu bar, keeping configuration actions logically grouped in a single settings pane.

### 3. API Credentials Layout
- **Decision**: Implement text fields for OpenRouter API keys and Local Llama server endpoints bound directly to `UserDefaults` using SwiftUI's `@AppStorage`.
- **Rationale**: Provides instant state synchronization, standard visual security, and ensures Phase 3 has a clean foundation to read keys immediately.

## Risks / Trade-offs

- **[Risk] Audio stream stuttering during input swaps in the settings pane**
  - *Mitigation*: Trigger audio tap re-initialization asynchronously on a background queue when an input device or capture source is switched, ensuring the main thread and UI transitions remain responsive.
