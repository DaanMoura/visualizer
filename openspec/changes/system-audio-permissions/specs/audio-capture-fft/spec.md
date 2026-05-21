## MODIFIED Requirements

### Requirement: Driverless System Audio Capture
The application SHALL support capturing system-wide internal audio natively using macOS `ScreenCaptureKit` without requiring virtual audio drivers or external dependencies. To prevent the application from getting stuck on a permission request view, the system SHALL check and accept either full **Screen & System Audio Recording** OR **System Audio Recording Only** permission, utilizing an asynchronous preflight check via `SCShareableContent` fallback when `CGPreflightScreenCaptureAccess()` returns false.

#### Scenario: System Audio Capture
- **WHEN** the system audio source option is selected and either Screen & System Audio Recording or System Audio Recording Only permission is granted
- **THEN** the system starts an `SCStream` capturing internal speaker output, converts `CMSampleBuffer` frames into standard PCM buffers, and routes them to the FFT processor.
