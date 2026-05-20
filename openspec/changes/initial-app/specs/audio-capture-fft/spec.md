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
