## ADDED Requirements

### Requirement: Real-Time Audio Buffer Capture
The system SHALL tap the default macOS input device's microphone audio input using `AVAudioEngine` at a standard sample rate, converting captured sound into real-time PCM buffers.

#### Scenario: Audio Capture Active
- **WHEN** the application is active and permissions are granted
- **THEN** the system installs a tap on the input node and streams audio buffer data.

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
