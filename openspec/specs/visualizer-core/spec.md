# visualizer-core Specification

## Purpose
TBD - created by archiving change initial-app. Update Purpose after archive.
## Requirements
### Requirement: Application Startup & Window Scaffolding
The application SHALL launch a single, resizable macOS window containing the visualization view, with a distraction-free user interface that excludes HUD overlays, diagnostics, routing controls, status labels, and instructional overlay text.

#### Scenario: Application Launch
- **WHEN** the user launches the Sound Visualizer application
- **THEN** a window is displayed showing the active visualizer in windowed state, with no HUD or diagnostic overlay visible.

#### Scenario: Active Visualization Surface
- **WHEN** audio capture is active
- **THEN** the window contains ONLY the rendered visualization surface, with no in-window audio device selector, signal level indicator, live/offline status label, or help text controls.

### Requirement: Fullscreen Window Modes
The application SHALL support toggling between windowed and native macOS fullscreen modes. Toggling SHALL be triggered by pressing the 'F' key, double-clicking the visualization canvas, or clicking the standard window controls.

#### Scenario: Toggle Fullscreen via Keyboard
- **WHEN** the user presses the 'F' key on the keyboard
- **THEN** the main window toggles its state between windowed and native macOS fullscreen mode.

#### Scenario: Toggle Fullscreen via Double-Click
- **WHEN** the user double-clicks within the visualizer view area
- **THEN** the main window toggles its state between windowed and native macOS fullscreen mode.

### Requirement: Dynamic Permission Onboarding
The application SHALL dynamically verify required permissions based on the active audio source. If capturing from microphone/input-devices and microphone permission is denied, it SHALL present a clean, elegant warning UI explaining how the user can grant permission in macOS System Settings. If capturing from system audio and screen recording permission is denied, it SHALL present a clean, elegant warning UI explaining how the user can grant screen recording permission.

#### Scenario: Screen Recording Permission Denied
- **WHEN** the system audio source is selected and the Screen Recording permission is denied or restricted
- **THEN** the main window displays a helpful explanation screen instead of the visualizer, prompting the user to enable permissions in macOS Settings.

#### Scenario: Microphone Permission Denied
- **WHEN** an input-device source is selected and the microphone permission is denied or restricted
- **THEN** the main window displays a helpful explanation screen instead of the visualizer, prompting the user to enable permissions in macOS Settings.

### Requirement: Active Visualizer Rendering Host
The visualization view SHALL host the currently active visualizer style, supplying it with real-time frequency-domain and/or time-domain PCM data. Swapping the active style SHALL instantly update the rendering view to the new style.

#### Scenario: Display Active Visualizer Style
- **WHEN** a visualizer style is selected as active
- **THEN** the visualization surface hosts and renders that specific style using real-time audio data.

