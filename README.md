# Sound Visualizer for macOS

A simple, fast, and elegant macOS application that visualizes ambient or system audio in real-time, inspired by classic media player visualizers (like Windows Media Player's legacy visualizers).

## 🎶 Overview

This project is built from the ground up to be lightweight, high-performance, and distraction-free. It focuses strictly on rendering beautiful real-time audio visualizations with zero bloat.

### Key Features
- **Pure Visualizer:** No music players, playlists, or complex libraries—just gorgeous real-time visualizers.
- **Microphone / System Audio Input:** Captures sound input in real-time and analyzes frequencies using AVFoundation / Accelerate framework (FFT).
- **Smooth Windowing:** Resizable window with instant visual adaptation and seamless toggle to Native Fullscreen mode.
- **Classic Styles:** Cycle through multiple visualizer styles (e.g., retro spectrum bars, wave oscilloscopes, frequency fire, and psychedelic lines).
- **Extreme Performance:** Built using Swift with Metal or highly optimized Core Graphics rendering to ensure high refresh rates and minimal CPU/GPU overhead.

---

## 🛠 Tech Stack

- **Platform:** macOS 13+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI or AppKit (optimized for low-latency windowing)
- **Audio Processing:** AVFoundation, CoreAudio, and the Accelerate framework (for FFT processing)
- **Rendering:** Metal or Core Graphics / SpriteKit for fluid high-framerate rendering

---

## 📂 Project Structure

*(To be populated as the application components are initialized)*
- `/Visualizer` - Core Swift Xcode Project / Source files
- `/Visualizer/Audio` - Audio capture and FFT analysis engine
- `/Visualizer/Renderers` - Visualizer styles (Bars, Waves, etc.) and graphics logic
- `/Visualizer/Views` - SwiftUI / Cocoa views and window controller logic

---

## 🚀 Getting Started

### Prerequisites
- macOS Ventura (13.0) or later
- Xcode 15 or later
- Microphone / Input device permissions (granted on first launch)

### Building
1. Open the project folder in Xcode or Swift Package Manager.
2. Build and run (⌘R).
3. Choose your audio input source and start playing sound!

---

## 🎛 Controls
- **F / Double Click:** Toggle Fullscreen Mode
- **Space / Left-Right Arrow:** Cycle through visualizer styles
- **Esc:** Exit fullscreen mode
