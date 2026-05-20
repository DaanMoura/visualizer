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
  - *Path A (Raw Microphone):* Easy to set up, but captures room/ambient noise.
  - *Path B (Virtual Loopback Driver Support):* Captures pure digital system output by reading from a virtual input driver (e.g., BlackHole). It uses standard `AVAudioEngine` and standard **Microphone Permissions**, keeping the app lightweight and free from persistent OS screen recording indicators.
  - *Path C (ScreenCaptureKit):* Captures system audio directly but triggers intrusive **Screen Recording Permissions** and leaves a permanent recording dot in the macOS menu bar, disrupting the minimalist aesthetic.
  **Path B was chosen** because it achieves 100% pure audio capture with lightweight code and clean privacy states, while naturally allowing users to opt into a free virtual loopback driver (like BlackHole) or fallback to their standard microphone.
- **Alternative considered:** CoreAudio AudioUnits (more boilerplate) or ScreenCaptureKit (too intrusive / high overhead).

### 3. DSP: Apple Accelerate Framework (vDSP DFT/FFT)
- **Choice:** `vDSP_DFT_zop` / Discrete Fourier Transform helper functions in the Accelerate framework.
- **Rationale:** Native, extremely fast, hardware-optimized vector math. It allows us to compute FFT in real time with near-zero CPU overhead.
- **Alternative considered:** Custom Swift FFT implementation (much slower, high CPU cost).

### 4. Graphic Rendering: SwiftUI Canvas
- **Choice:** SwiftUI Canvas (`Canvas { context, size in ... }`).
- **Rationale:** SwiftUI Canvas uses a high-performance Core Graphics context under the hood, drawing directly to hardware-accelerated buffers. It is perfectly suited for drawing 2D shapes (vertical bars and dots) at 60+ FPS, supports modern rendering effects like drop shadows, neon-style blur effects, and smooth linear gradients easily, and scales automatically during window resizes.
- **Alternative considered:** Metal API (high setup boilerplate, only necessary for complex 3D or particle simulations; Canvas is highly optimized and perfectly sufficient for 2D spectrum bars).

### 5. Animation and Physics: Exponential Decay + Gravity Peak Fall
- **Choice:** Real-time frame-based interpolation for bar heights and physics-based gravity formulas for falling peaks.
- **Rationale:** Directly plotting raw FFT amplitudes leads to jarring, jittery movements. We will apply:
  1. An exponential decay filter to bar heights: `currentValue = currentValue * decay + targetValue * (1 - decay)`.
  2. A "hang time" followed by linear/quadratic gravity acceleration descent for the peak indicator dots.
  This replicates the fluid, tactile response of high-end classic physical spectrum visualizers.

## Risks / Trade-offs

- **[Risk] Microphone Permissions Denied:**
  - *Mitigation:* The app will check microphone permissions on start. If denied, it displays a beautiful placeholder view directing the user to Apple System Settings, updating dynamically if permissions are changed.
- **[Risk] User Onboarding for Virtual Drivers (BlackHole):**
  - *Mitigation:* If the audio input level is flat or the user is setting up the app, we can provide subtle, elegant text instructions or a README guide pointing them to download/install BlackHole to route their internal audio safely and cleanly.
- **[Risk] Window Resize Render Performance:**
  - *Mitigation:* SwiftUI `Canvas` handles resizing natively and extremely fast. We will avoid dynamic array allocations in the render loop; instead, we will use a pre-allocated array of visualizer models, adjusting only the layout math inside the Canvas block based on the current context bounds.
- **[Risk] Audio Input Route Changes (e.g., unplugging mic / changing virtual driver settings):**
  - *Mitigation:* Observe `AVAudioEngineConfigurationChange` notifications and automatically restart or re-configure the audio capture stream.
