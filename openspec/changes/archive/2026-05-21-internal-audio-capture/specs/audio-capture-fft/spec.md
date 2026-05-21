## MODIFIED Requirements

### Requirement: Real-Time Audio Buffer Capture
The system SHALL tap the selected audio source (either the active input device or the system-wide internal audio via `ScreenCaptureKit`) at a standard sample rate, converting captured sound into real-time PCM buffers. If no source has been explicitly selected, the system SHALL default to the system default input device.

#### Scenario: Audio Capture Active
- **WHEN** the application is active and permissions are granted
- **THEN** the system installs a tap on the selected (or default) capture path (AVAudioEngine input node or ScreenCaptureKit stream) and streams audio buffer data.

#### Scenario: Selected Device Unavailable
- **WHEN** the previously selected input device is removed, becomes unavailable, or reports an incompatible format
- **THEN** the system falls back to the default macOS audio input and resumes capture without requiring an app restart.

## ADDED Requirements

### Requirement: Driverless System Audio Capture
The application SHALL support capturing system-wide internal audio natively using macOS `ScreenCaptureKit` without requiring virtual audio drivers or external dependencies.

#### Scenario: System Audio Capture
- **WHEN** the system audio source option is selected and screen recording permission is granted
- **THEN** the system starts an `SCStream` capturing internal speaker output, converts `CMSampleBuffer` frames into standard PCM buffers, and routes them to the FFT processor.
