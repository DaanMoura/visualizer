## ADDED Requirements

### Requirement: Native Secondary Settings Window
The application SHALL host a dedicated native Settings window, separate from the primary visualizer window. The Settings window SHALL adopt standard macOS utility layouts, complete with visual tab groupings for Audio Settings, API Credentials, and Shader Library.

#### Scenario: Display Settings Window
- **WHEN** the Settings window is opened
- **THEN** it displays a clean, tabbed, or split-pane view with dedicated tabs for Audio, API Credentials, and Shader Library.

### Requirement: Audio Capture Control
The Settings window SHALL allow the user to switch the active capture source (Microphone vs. System Audio) and select from available physical audio input devices.

#### Scenario: Switch Audio Source
- **WHEN** the user selects "System Audio" in the Settings window
- **THEN** the active visualizer instantly updates its audio tap to capture native internal audio.

#### Scenario: Switch Input Device
- **WHEN** the user picks a different microphone input from the device dropdown list
- **THEN** the active visualizer switches its audio input node to the new device on-the-fly.

### Requirement: API Provider Configurations
The Settings window SHALL let the user input and persist API credentials for OpenRouter and specify a custom local Llama server connection URL.

#### Scenario: Save OpenRouter Key
- **WHEN** the user enters an OpenRouter API key and closes or saves the window
- **THEN** the system stores the key securely in UserDefaults for use during subsequent AI generation tasks.

#### Scenario: Select Local Llama Endpoint
- **WHEN** the user inputs a custom endpoint URL (e.g. `http://localhost:11434`) and closes the window
- **THEN** the system registers the endpoint URL.
