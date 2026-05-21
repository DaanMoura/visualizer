## Context

The macOS Sound Visualizer requires a dynamic rendering framework that enables seamless transitioning between multiple visualization styles in real-time. Currently, the application is limited to a static visualizer style (`SpectrumBarsVisualizer`) and does not support runtime visualizer swapping or alternative rendering inputs (such as time-domain PCM waveforms).

To support a premium retro-modern aesthetic, the app must provide:
1. **Dynamic Swapping**: Seamlessly transition visualizer styles at runtime without restarting, disconnecting, or interrupting the active audio capture streams.
2. **Accessible Selection**: Easy UI access via a native macOS menu bar item and keyboard arrow key navigation (Left/Right) on the visualization view.
3. **Advanced Visualizations**: Multiple styles leveraging distinct data streams, including frequency-domain (FFT) and time-domain (raw PCM amplitude) data.
4. **Metal-Based GPU Rendering**: First-class GPU acceleration using Metal to render complex interactive effects like particles at 60+ FPS with zero CPU overhead.

---

## Goals / Non-Goals

**Goals:**
- **Modular Renderer Architecture**: Define a standardized view-switching system that selects and renders visualizers dynamically.
- **Dual Data Stream Support**: Extend `AudioEngineManager` to stream both frequency-domain (32 FFT bands) and real-time time-domain PCM buffers (512 samples) concurrently.
- **Native macOS Menu Bar Integration**: Add a "Visualisation" command menu to the macOS app shell with checkmark items to switch visualizer styles.
- **Suppress Keyboard Alert Beeps**: Capture Left and Right arrow keys in the local keyboard event monitor and suppress default macOS beep notification sounds by properly consuming the events.
- **Native Metal Rendering Pipeline**: Build a dedicated Metal visualizer (`MetalParticleVisualizer`) utilizing a custom `MTKView`, `MTKViewDelegate` rendering loop, and Metal Shading Language (MSL) shaders.
- **High-Performance Implementations**: Design three new visualizers:
  1. `OscilloscopeVisualizer`: Continuous, neon-glowing wave representing raw time-domain PCM buffers.
  2. `FrequencyVortexVisualizer`: Dynamic center-radial line scaling and continuous rotation driven by real-time frequency-domain values.
  3. `MetalParticleVisualizer`: GPU-accelerated field of thousands of glowing neon particles orbiting and responding to audio beats and overall RMS signal levels.

**Non-Goals:**
- **OpenGL/GLSL Integration**: We will not use OpenGL/GLSL because OpenGL is deprecated on macOS and lacks modern performance features.
- **Complex Sidebar/HUD Visualizer Configs**: No in-window list views, custom controls, or floating sidebars. Visualizer styles should be completely distraction-free.

---

## Decisions

### 1. Style Selection State Placement
- **Decision**: Host the `VisualizerStyle` enumeration and selection state directly inside `AudioEngineManager`.
- **Rationale**: `AudioEngineManager` is already registered as an `@EnvironmentObject` accessible by the entire view tree (`VisualizerView`, `VisualizerApp`, and individual visualizers). Hosting the active style state inside the manager allows the menu items in the app shell, the key monitors in the view, and the rendering surface to react instantly to state changes.

### 2. Time-Domain PCM Buffering
- **Decision**: Add a `@Published var rawSamples: [Float]` array of 512 elements to `AudioEngineManager` and fill it by downsampling incoming audio frames inside `processAudioBuffer(_:)`.
- **Rationale**: A buffer size of 512 samples provides a high-fidelity representation of the waveform for a 60 FPS drawing frame without causing heavy CPU/memory overhead or allocations. Downsampling ensures consistent array sizing regardless of whether the incoming device uses 1024 or larger capture buffers.

### 3. Native Metal Pipeline via MTKView
- **Decision**: Reject OpenGL/GLSL in favor of Apple's **Metal framework** using a custom `MTKView` represented in SwiftUI via `NSViewRepresentable`. We will write native MSL (Metal Shading Language) shaders for high-performance GPU particle rendering.
- **Rationale**: OpenGL/GLSL is officially deprecated by Apple and operates poorly on Apple Silicon. Metal offers direct, low-level, high-performance GPU access. Using an `MTKView` with an active drawing loop (`draw(in:)` delegate) allows us to render particle systems fluidly at ProMotion refresh rates (up to 120 FPS) with virtually zero energy impact.

### 4. Metal Particle System Architecture
- **Decision**: Maintain a Swift structure representation of particle physics updated on each frame, passing the coordinates into a Metal vertex shader as a vertex buffer, and utilizing a fragment shader for smooth, additive glow blending.
```swift
struct MetalParticle {
    var position: simd_float2
    var velocity: simd_float2
    var color: simd_float4
    var size: Float
}
```
- **Rationale**: Processing particle physics in Swift for a moderate particle count (e.g. 5,000 to 10,000) is highly performant and easily customizable. The Metal vertex shader then maps the points, and the fragment shader draws circular, glowing anti-aliased dots by computing distance-to-center gradients:
```metal
// MSL Fragment Shader Glow Formula
float dist = length(input.point_coord - float2(0.5));
float alpha = 1.0 - smoothstep(0.0, 0.5, dist);
float glow = exp(-dist * 4.0); // Neon exponential decay
return float4(input.color.rgb * glow, alpha * input.color.a);
```

### 5. Arrow Key Navigation & Beep Suppression
- **Decision**: Handle the `.leftArrow` and `.rightArrow` keys inside `NSEvent.addLocalMonitorForEvents(matching: .keyDown)` in `VisualizerView.swift` and return `nil`.
- **Rationale**: Standard macOS event propagation sounds an alert beep when arrow keys are pressed in a view with no focus. Returning `nil` from the local event monitor intercepts and fully consumes the key event, preventing the system from producing warning beeps while allowing visualizer cycling.

---

## Risks / Trade-offs

### [Risk] Particle Update Thread Bottlenecks
- **Description**: Running physics updates on the main thread for 10,000 particles could impact UI responsiveness.
- **Mitigation**: Perform particle state updates inside the `MTKView` draw loop which runs on an independent rendering/dispatch thread, keeping the main thread free for SwiftUI layout updates.

### [Risk] Frame Drops on Visualizer Switch
- **Description**: Initializing a Metal device and pipeline state on a visualizer swap could cause a minor frame drop.
- **Mitigation**: Precompile and cache the Metal Pipeline State Object (PSO) when the app launches or when `MetalParticleVisualizer` is initialized, avoiding compile delays when the style is selected.
