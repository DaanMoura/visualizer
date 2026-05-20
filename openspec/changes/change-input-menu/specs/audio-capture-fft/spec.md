## MODIFIED Requirements

### Requirement: Real-Time Audio Buffer Capture
The system SHALL tap the selected macOS audio input device using `AVAudioEngine` at a valid device sample rate, converting captured sound into real-time PCM buffers. If no explicit input has been selected or the selected input is unavailable, the system SHALL fall back to the default macOS input device.

#### Scenario: Audio Capture Active
- **WHEN** the application is active and permissions are granted
- **THEN** the system installs a tap on the selected input path and streams audio buffer data.

#### Scenario: Selected Device Unavailable
- **WHEN** the selected audio input device is removed, unavailable, or reports an invalid capture format
- **THEN** the system falls back to the default macOS input device and continues attempting to capture valid PCM buffers.

## ADDED Requirements

### Requirement: Native Audio Input Menu
The application SHALL provide a native macOS menu bar control for selecting the active audio input device. The menu SHALL list available input-capable devices, including loopback devices such as BlackHole when installed, and SHALL indicate the currently selected device.

#### Scenario: Select Input Device
- **WHEN** the user selects an input device from the macOS menu bar
- **THEN** the system stores that selection, reconfigures audio capture to use the selected device, and resumes visualizer updates without requiring an application restart.

#### Scenario: Loopback Device Listed
- **WHEN** a loopback input device such as BlackHole is installed and available to Core Audio
- **THEN** the input menu includes that device as a selectable audio source.

### Requirement: Audio Input Device Refresh
The system SHALL refresh the available audio input device list when audio hardware configuration changes are detected so the menu reflects connected, disconnected, or renamed devices.

#### Scenario: Device List Changes
- **WHEN** macOS reports an audio configuration change
- **THEN** the system refreshes the input device list and updates the selected-device state if the previous selection is no longer available.
