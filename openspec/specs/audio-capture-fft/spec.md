# audio-capture-fft Specification

## Purpose
TBD - created by archiving change initial-app. Update Purpose after archive.
## Requirements
### Requirement: Real-Time Audio Buffer Capture
The system SHALL tap the selected audio source (either the active input device or the system-wide internal audio via `ScreenCaptureKit`) at a standard sample rate, converting captured sound into real-time PCM buffers. If no source has been explicitly selected, the system SHALL default to the system default input device.

#### Scenario: Audio Capture Active
- **WHEN** the application is active and permissions are granted
- **THEN** the system installs a tap on the selected (or default) capture path (AVAudioEngine input node or ScreenCaptureKit stream) and streams audio buffer data.

#### Scenario: Selected Device Unavailable
- **WHEN** the previously selected input device is removed, becomes unavailable, or reports an incompatible format
- **THEN** the system falls back to the default macOS audio input and resumes capture without requiring an app restart.

### Requirement: Native Audio Input Menu
The application SHALL provide a native macOS menu bar control (under the app menu or a dedicated menu) that lists all input-capable audio devices currently available on the system, including loopback devices such as BlackHole. The menu SHALL indicate the currently selected device and allow the user to switch the active audio input.

#### Scenario: Select Input Device
- **WHEN** the user selects a device from the audio input menu
- **THEN** the system stores the selection, reconfigures the audio capture to use the chosen device, and resumes audio capture without requiring an app restart.

#### Scenario: Loopback Device Listed
- **WHEN** a loopback audio device (e.g. BlackHole) is installed and available
- **THEN** it appears in the input device menu alongside physical microphone inputs.

### Requirement: Audio Input Device Refresh
The system SHALL monitor macOS audio hardware configuration changes and refresh the list of available input devices accordingly. If the previously selected device is no longer present after a refresh, the system SHALL update the selected-device state to reflect the fallback.

#### Scenario: Device List Changes
- **WHEN** the macOS audio configuration changes (e.g. a device is connected or disconnected)
- **THEN** the system refreshes the available device list and updates the selected-device state if the previous selection is no longer available.

### Requirement: Real-Time FFT Frequency Analysis
The system SHALL process PCM audio buffers using Apple's `Accelerate` / `vDSP` library to perform a Fast Fourier Transform (FFT). The raw output frequencies SHALL be grouped into frequency bins (such as Bass, Mids, and Treble) with a linear or exponential decay filter to prevent jittery changes.

#### Scenario: FFT Calculation
- **WHEN** real-time PCM audio buffers are captured
- **THEN** the system computes the FFT, updates frequency bins, and applies a smoothing/decay algorithm to create organic-looking transitions.

### Requirement: Logarithmic Decibel Sensitivity Calibration
The system SHALL scale raw frequency amplitudes logarithmically using standard decibel calculations (`20 * log10(max(amplitude, 1e-5))`), mapping values between a minimum floor (e.g. `-65 dB`) and a maximum ceiling (e.g. `-15 dB`) to a standard normalized output range of `[0.0, 1.0]`. This ensures the visualizer is highly sensitive to standard low-to-medium digital stream volumes.

#### Scenario: Sensitive Amplitude Scaling
- **WHEN** raw frequency amplitudes are calculated from input audio
- **THEN** the system normalizes them using the decibel-floor mapping to prevent low-amplitude digital streams from appearing frozen or static at 0% height.

### Requirement: Driverless System Audio Capture
The application SHALL support capturing system-wide internal audio natively using macOS `ScreenCaptureKit` without requiring virtual audio drivers or external dependencies.

#### Scenario: System Audio Capture
- **WHEN** the system audio source option is selected and screen recording permission is granted
- **THEN** the system starts an `SCStream` capturing internal speaker output, converts `CMSampleBuffer` frames into standard PCM buffers, and routes them to the FFT processor.

