## MODIFIED Requirements

### Requirement: Application Startup & Window Scaffolding
The application SHALL launch a single, resizable macOS window containing only the visualization view during normal active playback, with a distraction-free user interface that excludes HUD, diagnostics, routing controls, status labels, and instructional overlay text.

#### Scenario: Application Launch
- **WHEN** the user launches the Sound Visualizer application and audio permissions are granted
- **THEN** a window is displayed showing the active visualizer, defaulting to a windowed state, with no HUD or diagnostic overlay visible.

#### Scenario: Active Visualization Surface
- **WHEN** audio capture is active and the visualizer is rendering
- **THEN** the visualizer window contains only the rendered visualization surface and no in-window audio device, signal level, live/offline status, or help text controls.

### Requirement: Fullscreen Window Modes
The application SHALL support toggling between windowed and native macOS fullscreen modes. Toggling SHALL be triggered by pressing the 'F' key, double-clicking the visualization canvas, or clicking the standard window controls.

#### Scenario: Toggle Fullscreen via Keyboard
- **WHEN** the user presses the 'F' key on the keyboard
- **THEN** the main window toggles its state between windowed and native macOS fullscreen mode.

#### Scenario: Toggle Fullscreen via Double-Click
- **WHEN** the user double-clicks within the visualizer view area
- **THEN** the main window toggles its state between windowed and native macOS fullscreen mode.
