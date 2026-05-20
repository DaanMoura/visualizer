# visualizer-core Specification

## Purpose
TBD - created by archiving change initial-app. Update Purpose after archive.
## Requirements
### Requirement: Application Startup & Window Scaffolding
The application SHALL launch a single, resizable macOS window containing the visualization view, with a distraction-free user interface.

#### Scenario: Application Launch
- **WHEN** the user launches the Sound Visualizer application
- **THEN** a window is displayed showing the active visualizer, defaulting to a windowed state.

### Requirement: Fullscreen Window Modes
The application SHALL support toggling between windowed and native macOS fullscreen modes. Toggling SHALL be triggered by pressing the 'F' key, double-clicking the visualization canvas, or clicking the standard window controls.

#### Scenario: Toggle Fullscreen via Keyboard
- **WHEN** the user presses the 'F' key on the keyboard
- **THEN** the main window toggles its state between windowed and native macOS fullscreen mode.

#### Scenario: Toggle Fullscreen via Double-Click
- **WHEN** the user double-clicks within the visualizer view area
- **THEN** the main window toggles its state between windowed and native macOS fullscreen mode.

### Requirement: Microphone Permission Handling
The application SHALL verify microphone input permissions upon launching. If permissions are not granted, it SHALL present a clean, elegant warning UI explaining how the user can grant permission in macOS System Settings.

#### Scenario: Microphone Permission Denied
- **WHEN** the app starts up and the microphone permission is denied or restricted
- **THEN** the main window displays a helpful explanation screen instead of the visualizer, prompting the user to enable permissions in macOS Settings.

