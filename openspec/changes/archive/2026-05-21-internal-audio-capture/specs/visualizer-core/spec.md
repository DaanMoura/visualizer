## ADDED Requirements

### Requirement: Dynamic Permission Onboarding
The application SHALL dynamically verify required permissions based on the active audio source. If capturing from microphone/input-devices and microphone permission is denied, it SHALL present a clean, elegant warning UI explaining how the user can grant permission in macOS System Settings. If capturing from system audio and screen recording permission is denied, it SHALL present a clean, elegant warning UI explaining how the user can grant screen recording permission.

#### Scenario: Screen Recording Permission Denied
- **WHEN** the system audio source is selected and the Screen Recording permission is denied or restricted
- **THEN** the main window displays a helpful explanation screen instead of the visualizer, prompting the user to enable permissions in macOS Settings.

#### Scenario: Microphone Permission Denied
- **WHEN** an input-device source is selected and the microphone permission is denied or restricted
- **THEN** the main window displays a helpful explanation screen instead of the visualizer, prompting the user to enable permissions in macOS Settings.
