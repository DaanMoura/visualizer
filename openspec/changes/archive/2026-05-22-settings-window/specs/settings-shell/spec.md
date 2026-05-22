## ADDED Requirements

### Requirement: Native Secondary Settings Window
The application SHALL host a dedicated native Settings window, separate from the primary visualizer window. The Settings window SHALL adopt standard macOS utility layouts, complete with sidebar items for Audio Settings and the Shader Library placeholder.

#### Scenario: Display Settings Window
- **WHEN** the Settings window is opened
- **THEN** it displays a clean sidebar split view with options for Audio Settings and the Shader Library.

### Requirement: Audio Capture Control
The Settings window SHALL allow the user to switch the active capture source (Microphone vs. System Audio) and select from available physical audio input devices.

#### Scenario: Switch Audio Source
- **WHEN** the user selects "System Audio" in the Settings window
- **THEN** the active visualizer instantly updates its audio tap to capture native internal audio.

#### Scenario: Switch Input Device
- **WHEN** the user picks a different microphone input from the device dropdown list
- **THEN** the active visualizer switches its audio input node to the new device on-the-fly.
