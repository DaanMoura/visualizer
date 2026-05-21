## MODIFIED Requirements

### Requirement: Real-Time Audio Buffer Capture
The system SHALL tap the selected audio source (either the active input device or the system-wide internal audio via `ScreenCaptureKit`) at a standard sample rate, converting captured sound into real-time PCM buffers. If no source has been explicitly selected or persisted, the system SHALL default to the `System Audio` (internal driverless) capture source at startup to preserve system-wide speaker audio quality. When capturing from `System Audio` or when capture is stopped, the system SHALL completely release and deallocate `AVAudioEngine` resources to prevent triggering unwanted microphone sessions.

#### Scenario: Audio Capture Active
- **WHEN** the application is active and permissions are granted
- **THEN** the system installs a tap on the selected (or default) capture path (AVAudioEngine input node or ScreenCaptureKit stream) and streams audio buffer data.

#### Scenario: Selected Device Unavailable
- **WHEN** the previously selected input device is removed, becomes unavailable, or reports an incompatible format
- **THEN** the system falls back to the default macOS audio input and resumes capture without requiring an app restart.

## ADDED Requirements

### Requirement: Audio Capture State Persistence
The system SHALL persist the user's selected capture source across application launches.

#### Scenario: Launch with Persisted Source
- **WHEN** the application launches and a previously selected capture source is saved in user preferences
- **THEN** the system automatically restores that capture source and initializes the corresponding capture stream.
