# macOS Sound Visualizer: Agent Context & Guidelines (AGENTS.md)

Welcome, Antigravity and Codex! This document serves as your operational blueprint, architecture guide, and style manual for building the **macOS Sound Visualizer**. 

---

## 🎯 Project Core Mission
Build a **simple, lightning-fast, and elegant** sound visualizer for macOS. 
- **Core Scope:** Displays only the visualizer.
- **Interactions:** Support window resizing, toggling native fullscreen mode, and switching visualizer styles.
- **Strict Non-goals:** NO playlists, music libraries, advanced audio configuration panels, equalizers, or complicated sidebar menus. Keep it completely distraction-free and focused.

---

## 🛠 Tech Stack & Architecture

To maintain maximum performance and a lightweight footprint, follow these implementation paths:

- **Language:** Modern Swift 5.9+ (utilizing structured concurrency safely where necessary).
- **UI & Window Shell:** SwiftUI for the main window lifecycle, hosting custom graphics contexts.
- **Audio Capture:** Apple's native `AVFoundation` framework (using `AVAudioEngine` and tap on `AVAudioInputNode`). Must support permission requests and handles microphone or loopback input cleanly.
- **Digital Signal Processing (DSP):** Apple's native `Accelerate` framework (utilizing `vDSP` functions) to compute Fast Fourier Transforms (FFT) in real-time with minimal CPU overhead.
- **Graphics & Rendering:** SwiftUI custom `Canvas`, `Metal`, or optimized `CoreGraphics` to render visualizers fluidly at 60+ FPS (or ProMotion refresh rates) while keeping CPU/GPU thermal impact minimal.

---

## 🎨 Visual & Aesthetic Standards

- **Retro-Modern Styling:** Take visual inspiration from classic Windows Media Player and Winamp visualizers, but elevate them with rich modern graphics:
  - Harmonious, vibrant dark-mode-first color palettes (avoiding raw primary colors).
  - Smooth neon glows, gradient fills, and subtle motion blur/fade trails.
  - Fluid physics-based movements (e.g. spring-based animations for amplitude rises, linear/exponential decay for drops).
- **Pixel-Perfect Adaptability:** Visualizers must instantly respond to window size changes and fullscreen toggles without restarting audio taps, stretching elements, or dropping frames.

---

## 📦 Key Component Blueprints

1. **`AudioEngine`:**
   - Manages the state of `AVAudioEngine`.
   - Handles permission states (requesting, checking, presenting custom warning UI if denied).
   - Installs an audio tap on the input node to grab buffers.

2. **`FFTProcessor`:**
   - Performs real-time Fourier analysis on incoming PCM buffers using `vDSP`.
   - Groups/smooths frequencies into distinct frequency bins (e.g. Bass, Mids, Treble).
   - Uses linear/exponential decay so that visual elements drop smoothly rather than bouncing jitterily.

3. **`VisualizerStyle` & Renderers:**
   - Define a modular design pattern (e.g. `VisualizerRenderer` protocol) to easily cycle through different styles:
     - **Spectrum Bars:** Glowing vertical bars with falling peak indicators.
     - **Oscilloscope Wave:** A smooth, glowing sinus wave representing the time-domain waveform.
     - **Frequency Vortex:** Visual elements scaling and rotating dynamically from the center.

---

## 📝 Code Conventions for Antigravity & Codex

1. **Native over Dependencies:** Rely exclusively on Apple's standard frameworks. Do not introduce CocoaPods, Swift Package Manager packages, or external frameworks unless absolutely unavoidable.
2. **Resource Management:** Ensure audio capture nodes and rendering loops are stopped/paused when the window is minimized, hidden, or closed to preserve system battery.
3. **Robustness & Edge Cases:** Ensure fully-functional implementation without using placeholder code. Gracefully handle conditions such as changing active audio input devices or permissions being revoked.

---

## 🤖 Custom AI Commands (Chat Shortcuts)

To streamline development, the user can trigger specific workflows using custom slash commands in the chat. As an AI Agent (Antigravity or Codex), you must intercept and execute these commands exactly as defined:

### `/commit`
When the user types `/commit` (optionally accompanied by instructions, e.g. `/commit "add Metal shaders"`, or just `/commit`), execute this automated pipeline:
1. **Analyze Workspace State:**
   - Run `git status` and inspect modified/untracked files.
   - Run `git diff` (or check changes) to understand the exact scope of the modifications.
2. **Draft a Conventional Commit Message:**
   - **Type:** Deduce the correct type:
     - `feat`: A new feature or component.
     - `fix`: A bug fix or error resolution.
     - `docs`: Documentation updates (e.g., changes to `README.md` or `AGENTS.md`).
     - `style`: Code style changes (formatting, spacing, etc.).
     - `refactor`: Structural code changes with no feature additions or fixes.
     - `perf`: Performance-enhancing changes.
     - `test`: Adding or updating tests.
     - `build` / `ci` / `chore`: Build files, CI configs, or maintenance tasks.
   - **Scope:** Identify the component (e.g., `audio`, `render`, `views`, `docs`, `scripts`). Use lowercase.
   - **Description:** A short, imperative description (e.g., `add oscilloscope wave visualizer`). Keep it lowercase and do not end with a period.
   - **Body/Footer:** If the changes are large or contain breaking changes, include an optional body and footer.
3. **Execute the Commit:**
   - Run the commit helper script in non-interactive mode:
     ```bash
     ./scripts/commit.sh <type> <scope> <description> [body] [footer]
     ```
     *(Use `-` for the scope if no specific scope applies.)*
4. **Confirm Success:** Show the user the generated commit message and a success confirmation of the Git commit.

