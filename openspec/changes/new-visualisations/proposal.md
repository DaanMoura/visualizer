## Why

To elevate the macOS Sound Visualizer's aesthetic experience, users need the ability to select and transition between different visualizer styles dynamically. A centralized method to swap visualizer styles via the system menu bar and seamlessly navigate them via keyboard arrow keys will provide a fluid, premium, and interactive user experience.

Furthermore, integrating a high-performance rendering pipeline using Apple's native **Metal framework** will enable extremely rich, GPU-accelerated graphics (such as fluid simulations, large particle systems, and blur trails) that maintain 60+ FPS (or ProMotion refresh rates) with zero CPU overhead.

## What Changes

- **Visualizer Swapping System**: Implement a modular styling architecture that supports real-time rendering style switches without interrupting or restarting the active audio capture stream.
- **Menu Bar Selection**: Integrate a system menu bar option to easily select the active visualizer style.
- **Keyboard Arrow Controls**: Support navigating to the next or previous visualizer style using the keyboard's `Left Arrow` and `Right Arrow` keys on the visualization surface.
- **New Visualizer Styles**: Add three new distinct visualization styles to test the swap system:
  1. **Oscilloscope Wave**: A smooth, glowing sine wave representing the time-domain PCM waveform.
  2. **Frequency Vortex**: Radial frequency lines scaling and rotating dynamically from the center.
  3. **Neon Particle Vortex (Metal-based)**: A GPU-accelerated system of thousands of glowing neon particles orbiting and responding dynamically to audio amplitudes, bass beats, and frequencies.
- **Metal Shader Pipeline**: Establish a native Metal rendering foundation (MTKView representable, pipeline states, and Metal Shading Language shaders) to support custom shaders.

## Capabilities

### New Capabilities
- `visualizer-swapping`: Supports dynamic switching, cycling, and persistent selection of visualizer styles via menu controls and arrow keys.
- `oscilloscope-renderer`: Time-domain waveform visualizer depicting raw amplitude pulses with smooth glowing trails.
- `vortex-renderer`: Center-radial frequency visualizer displaying bass, mids, and treble scale rotations.
- `metal-particles`: High-performance GPU-based particle field visualizer using Metal, rendering thousands of neon glowing particles that orbit and react to audio amplitudes.

### Modified Capabilities
- `visualizer-core`: Update the visualization surface host to handle key presses and display the selected renderer.

## Impact

- **`VisualizerView.swift`**: Integrates arrow key event handlers for visualizer switching and displays the selected visualizer, including the Metal-based particle view.
- **`AudioEngineManager.swift`**: Supplies frequency-domain data (amplitudes/FFT), time-domain PCM data (for the Oscilloscope), and overall RMS level (for Metal physics simulation).
- **`VisualizerApp.swift`**: Adds the active visualizer style menu list in the native macOS menu bar.
- **`Shaders.metal`**: High-performance Metal Shading Language (MSL) source code containing vertex and fragment shaders for the particle pipeline.
- **`MetalParticleVisualizer.swift`**: Custom SwiftUI `NSViewRepresentable` view wrapping `MTKView` and driving the Metal rendering loop.
