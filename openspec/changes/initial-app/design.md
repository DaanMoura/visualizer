## Context

To bootstrap the **macOS Sound Visualizer**, we are setting up the core architecture of the app from scratch. This includes the application's Swift entry point, real-time audio capture, Fast Fourier Transform (FFT) digital signal processing, and a high-performance rendering canvas. As specified by the `AGENTS.md` guidelines, we will rely strictly on native macOS frameworks (`AVFoundation`, `Accelerate`, `SwiftUI`) to ensure minimal footprint and maximum speed.

## Goals / Non-Goals

**Goals:**
- Create the Swift scaffolding for a native macOS desktop application.
- Implement an audio engine using `AVAudioEngine` to tap the active audio input device (physical microphone or virtual loopback driver) and request/observe privacy permissions.
- Implement real-time frequency analysis using the Apple `Accelerate` framework (`vDSP`) with custom frequency binning.
- Render a high-performance retro-modern "Spectrum Bars" visualization style at 60+ FPS using SwiftUI's hardware-accelerated `Canvas`.
- Support window resizing and native fullscreen modes dynamically.

**Non-Goals:**
- Multiple visualization styles (this initial app will feature only the Spectrum Bars visualization).
- Equalizer controls, audio file loading, or custom playlist players.
- Bundling or installing virtual audio loopback drivers (such as BlackHole) directly into the app bundle. Instead, the app relies on the user configuring their system sound output to a standard external virtual driver.

## Decisions

### 1. Application Scaffolding: SwiftUI App Lifecycle with AppKit Window Customization
- **Choice:** SwiftUI App lifecycle (`@main App`) combined with standard window modifiers.
- **Rationale:** SwiftUI provides an incredibly fast way to bootstrap the application lifecycle and rendering loop. Since we want an elegant, distraction-free visualizer, we will customize the SwiftUI window using modifiers like `.windowStyle(.hiddenTitleBar)` and setting a minimum/ideal size to make the visualizer feel premium and unified.

### 2. Audio Capture Architecture: Default Input Device Tap with Virtual Loopback Support (Path B)
- **Choice:** Tap the default system audio input node (`AVAudioInputNode`) using `AVAudioEngine`. Under this model, the visualizer captures whatever device is selected as the system default input.
- **Rationale:** We compared three paths for audio acquisition:
  - *Path A (Raw Microphone):* Easy to set up, but captures room/ambient noise (triggers orange microphone dot).
  - *Path B (Virtual Loopback Driver Support):* Captures pure digital system output by reading from a virtual input driver (e.g., BlackHole). It uses standard `AVAudioEngine` and standard **Microphone Permissions**, keeping the app lightweight. Note that on macOS Sonoma/Sequoia, capturing from any virtual driver triggers the **purple screen sharing/system audio recording dot** privacy indicator in the menu bar. This is a system-level security feature and cannot be bypassed.
  - *Path C (ScreenCaptureKit):* Captures system audio directly but triggers intrusive **Screen Recording Permissions** and also triggers the permanent **purple screen sharing dot** in the macOS menu bar, creating similar distraction with higher performance overhead.
  **Path B remains the best choice** because it achieves 100% pure audio capture with lightweight code, while naturally allowing users to route audio through a virtual loopback driver or fallback to their standard microphone.
- **Alternative considered:** CoreAudio AudioUnits (more boilerplate) or ScreenCaptureKit (too intrusive / high overhead).

### 3. DSP: Apple Accelerate Framework (vDSP DFT/FFT) — Fixed Window Size
- **Choice:** `vDSP_DFT_zop_CreateSetup` / Discrete Fourier Transform with a **fixed N=2048 window**, initialised once at startup.
- **Rationale:** Native, extremely fast, hardware-optimized vector math. It allows us to compute FFT in real time with near-zero CPU overhead.
- **Critical Implementation Note:** `vDSP_DFT_zop_CreateSetup` requires N = `2^a × 3^b × 5^c`. `AVAudioEngine` delivers buffers whose frame count depends on the hardware render slice (e.g. 4410 at 44.1 kHz), which does **not** satisfy this constraint. The DFT setup must therefore use a fixed power-of-2 size (2048 = 2^11) and each buffer must be copied/zero-padded into that fixed window before processing.
- **Alternative considered:** Custom Swift FFT implementation (much slower, high CPU cost); `vDSP_create_fftsetup` real FFT (same constraint, more complex split-complex packing required).

### 4. Graphic Rendering: Native SwiftUI `HStack` + `ForEach` Bar Views
- **Choice:** `HStack` + `ForEach` of individual `SpectrumBar` SwiftUI views with `.animation(.linear(duration:))` on each bar's height, rather than SwiftUI `Canvas`.
- **Rationale:** SwiftUI Canvas was the initial choice, but its draw closure executes **outside** SwiftUI's state-tracking graph. Accessing `@EnvironmentObject` properties inside `Canvas { ... }` does not register a dependency — so the canvas never re-renders when `@Published` amplitude arrays change, making bars appear frozen even though audio data is flowing correctly. Native `HStack/ForEach` views correctly participate in SwiftUI's reactive system.
- **Alternative considered:** `Canvas` with `TimelineView(.animation)` wrapper (drives redraws via display link but adds complexity); `Canvas` with `@State` + `.onChange` mirroring (works but adds a one-frame delay). Native views are simpler, correct, and SwiftUI animates transitions automatically.

### 5. Animation and Physics: Exponential Decay + Gravity Peak Fall (Direct Tap Update)
- **Choice:** Real-time frame-based interpolation for bar heights and physics-based gravity formulas for falling peaks, driven **directly** by the audio tap callback instead of `CVDisplayLink`.
- **Rationale:** Directly plotting raw FFT amplitudes leads to jarring, jittery movements. We will apply:
  1. An exponential decay filter to bar heights: `currentValue = currentValue * decay + targetValue * (1 - decay)`.
  2. A "hang time" followed by linear/quadratic gravity acceleration descent for the peak indicator dots.
  This replicates the fluid, tactile response of high-end classic physical spectrum visualizers.
  *Note on Robustness:* We originally designed a background rendering loop powered by `CVDisplayLink`. However, on specific macOS security contexts or virtual sound routing setups, `CVDisplayLink` threads can fail to fire or start cleanly. To guarantee absolute runtime robustness, we migrated the physics decay and peak tracking directly into the real-time audio tap callback (`processAudioBuffer`). This executes in perfect sync with the incoming digital audio stream and posts updates in a single, high-performance main-thread dispatch, ensuring the visualizer bars never freeze.

### 6. Amplitude Scaling and Sensitivity Calibration: Linear-to-dB Mapping
- **Choice:** Standard decibel range mapping (`dB = 20.0 * log10(max(amplitude, 1e-5))`) linearly normalized between `-90 dB` (noise floor) and `-10 dB` (loud signal ceiling) into a `[0, 1]` scalar range.
- **Rationale:** Standard digital audio streams at typical listening volumes produce FFT magnitudes around `-50 dB` to `-40 dB` after normalisation by the window size. The original `-65 dB` floor was still too high — signals were clipping below the floor and returning `0.0`. The correct floor for microphone and loopback signals is `-90 dB`, which accommodates the full dynamic range without compressing quiet passages to zero. A Hanning window is also applied before the FFT to reduce spectral leakage and concentrate energy into the correct bins.

## Risks / Trade-offs

- **[Risk] Microphone Permissions Denied:**
  - *Mitigation:* The app will check microphone permissions on start. If denied, it displays a beautiful placeholder view directing the user to Apple System Settings, updating dynamically if permissions are changed.
- **[Risk] User Onboarding & Silent Routing Issues (BlackHole):**
  - *Mitigation:* If the routing configuration is incorrect (e.g., Spotify is not outputting to BlackHole, or system input is wrong), the visualizer gets silent buffers. We will mitigate this by adding a **Diagnostics Overlay** to the UI displaying the **active input device name** and the **RMS average input volume in real-time**, making it simple for the user to troubleshoot physical/virtual device routing.
- **[Risk] Window Resize Render Performance:**
  - *Mitigation:* SwiftUI `Canvas` handles resizing natively and extremely fast. We will avoid dynamic array allocations in the render loop; instead, we will use a pre-allocated array of visualizer models, adjusting only the layout math inside the Canvas block based on the current context bounds.
- **[Risk] Audio Input Route Changes (e.g., unplugging mic / changing virtual driver settings):**
  - *Mitigation:* Observe `AVAudioEngineConfigurationChange` notifications and automatically restart or re-configure the audio capture stream.
