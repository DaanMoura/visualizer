## ADDED Requirements

### Requirement: Native Secondary Settings Window
The application SHALL host a dedicated native Settings window, separate from the primary visualizer window. The Settings window SHALL adopt standard macOS utility layouts, complete with visual grouping for Audio Capture, API credentials, and Custom Visualizers.

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
- **WHEN** the user enters an OpenRouter API key and hits close or save
- **THEN** the system stores the key securely in UserDefaults or Keychain for use during subsequent AI generation tasks.

#### Scenario: Select Local Llama Endpoint
- **WHEN** the user chooses the Local Llama provider and inputs a custom endpoint URL (e.g. `http://localhost:11434`)
- **THEN** the system registers the endpoint URL and validates the connection.

### Requirement: Custom Shader Library Editor
The Settings window SHALL provide a multi-line code editor or text area where users can list, select, view, write, and test custom MSL visualizer shaders.

#### Scenario: Activate Custom Shader
- **WHEN** the user selects a custom shader from the list and clicks "Run / Activate"
- **THEN** the system triggers the dynamic visualizer to compile and load the selected shader code.
