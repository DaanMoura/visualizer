# Sound Visualizer for macOS

A simple, fast, and elegant macOS application that visualizes ambient or system audio in real-time, inspired by classic media player visualizers (like Windows Media Player's legacy visualizers).

## 🎶 Overview

This project is built from the ground up to be lightweight, high-performance, and distraction-free. It focuses strictly on rendering beautiful real-time audio visualizations with zero bloat.

### Key Features
- **Pure Visualizer:** No music players, playlists, or complex libraries—just gorgeous real-time visualizers.
- **Microphone & System Audio Capture:** Accesses physical microphone inputs or internal system audio (loopback) in real-time with automatic permission state handling.
- **Dynamic Device Selection:** Switch capture sources (Microphone vs. System Audio) or pick specific microphone devices directly from the macOS menu bar.
- **Digital Signal Processing (DSP):** Real-time Fast Fourier Transform (FFT) analysis using Apple's Accelerate framework (`vDSP`) with logarithmic/exponential smoothing and peak decay for fluid visual drops.
- **Aesthetic Visualizer Styles:** Cycle through multiple stunning visualizer styles:
  - **Spectrum Bars:** Retro-modern glowing vertical bars with falling peak indicators and modern neon gradient fills.
  - **Oscilloscope Wave:** A smooth, neon-glowing sinus wave representing the time-domain waveform.
  - **Frequency Vortex:** Mesmerizing radial frequency bands that scale and rotate dynamically from the center.
  - **Neon Particle Vortex (Metal):** High-performance physics-based particle rendering powered by Apple's Metal API and custom MSL shaders at 60+ FPS.
- **Fluid macOS Window Shell:** Resizable window with instant visual adaptation, custom loading/permission screens, and robust audio-tap retention across sizing events.

---

## 🛠 Tech Stack

- **Platform:** macOS 13+ (Ventura or newer)
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI & AppKit integration (optimized for low-latency windowing)
- **Audio Processing:** `AVFoundation`, `CoreAudio`, `ScreenCaptureKit`, and `Accelerate` (vDSP)
- **Rendering Engine:** `Metal` (using MetalKit and MSL shaders) and optimized SwiftUI `Canvas` rendering

---

## 🚀 Getting Started

### Prerequisites
- macOS Ventura (13.0) or later
- Xcode 15 or later
- Microphone / Input device permissions (granted on first launch)

### Building & Running via Xcode (GUI)
1. Open the project folder in Xcode by opening `Visualizer/Visualizer.xcodeproj` or running:
   ```bash
   open Visualizer/Visualizer.xcodeproj
   ```
2. Build and run (⌘R).

### Building & Running via CLI (Command Line)
To build and run the application directly from your terminal:

1. **Build the App:**
   Run the following command to compile the visualizer and output the build product into the local `./Build` directory:
   ```bash
   xcodebuild -project Visualizer/Visualizer.xcodeproj -scheme Visualizer -configuration Debug -derivedDataPath ./Build
   ```

2. **Run the App:**
   - **As a standard window app:**
     ```bash
     open ./Build/Build/Products/Debug/Visualizer.app
     ```
   - **Directly inside your terminal (to stream real-time capture and device logs):**
     ```bash
     ./Build/Build/Products/Debug/Visualizer.app/Contents/MacOS/Visualizer
     ```

---

## 🔌 Tapping Internal System Audio (Pure Capture)

By default, the app captures audio from your Mac's default input device (physical microphone). To capture **pure, direct system sound** (e.g., from Spotify, Web Browsers, etc.) without background room noise:

1. **Install a Virtual Audio Driver:** Download and install a free virtual audio loopback driver like **BlackHole 2ch** (via Homebrew: `brew install blackhole-2ch` or direct installer).
2. **Create a Multi-Output Device (Optional but Recommended so you can hear it too!):**
   - Open **Audio MIDI Setup** on your Mac.
   - Click the **+** in the bottom left, select **Create Multi-Output Device**.
   - Check both your physical speakers/headphones AND **BlackHole 2ch**.
   - Right-click this Multi-Output Device and select **Use This Device For Sound Output**.
3. **Configure Sound Input:**
   - Go to **System Settings > Sound > Input**.
   - Choose **BlackHole 2ch** as your default system input device.
4. **Launch the Visualizer:** Open the Visualizer app. It will tap into the BlackHole stream and render 100% clean digital audio waveforms!

---

## 🎛 Controls

- **Double-Click / `F`:** Toggle Native Fullscreen Mode
- **`Esc`:** Exit Fullscreen Mode
- **Left / Right Arrow Keys:** Switch to the next/previous visualizer style instantly (with suppressed system alert beeps)
- **Command Shortcuts (⌘1 - ⌘4):** Jump directly to specific visualizer styles from the menu bar
- **Audio Input Menu:** Dynamic capture source and input device selection
