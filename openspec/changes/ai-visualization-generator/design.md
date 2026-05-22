## Context

The macOS Sound Visualizer is a distraction-free, zero-HUD native application that renders high-performance audio visualizations at 60+ FPS. Presently, changing configuration settings (e.g., input devices, active style) relies on system menu bar commands, and visualizers are statically compiled into the executable. 

To enable custom user-defined visualizations and lay the groundwork for AI-generated visualizers (via OpenRouter or local Llama models) without cluttering the clean main canvas, we need a dedicated native configuration window and a robust dynamic runtime rendering sandbox.

## Goals / Non-Goals

**Goals:**
- **Separate Config Shell**: A clean, native auxiliary window to configure audio inputs, persist LLM API keys (OpenRouter, Llama), and edit custom MSL shader code.
- **HUD-Free Main Window**: Completely maintain the distraction-free main visualizer window, transferring all input selectors and controls to the new settings panel.
- **Dynamic Shader Compilation**: Real-time MSL (Metal Shading Language) compilation at runtime utilizing `MTLDevice.makeLibrary(source:options:completionHandler:)`.
- **Audio-Uniform Data Pipeline**: Feed raw time-domain PCM samples and 512 FFT frequency bins directly into the dynamic Metal fragment shader on every frame.
- **Auto-Handled Compilation Errors**: Capture and report compilation warnings and syntax errors gracefully in the settings pane rather than crashing the graphics pipeline.

**Non-Goals:**
- **AI Prompt Logic (Next Phase)**: Network calls to OpenRouter/Llama, prompt templates, and AI-driven code self-healing are out of scope for this change. This change establishes the exact settings shell and dynamic compilation infrastructure.
- **Extensive Shader Asset Library**: Providing dozens of default custom shaders. We will implement one elegant dynamic template to verify compiling and feeding audio data.

## Decisions

### 1. Auxiliary Window Lifecycle via SwiftUI Multi-Window API
- **Decision**: Declare a secondary `Window` scene in `VisualizerApp` using `Window("Settings", id: "settings")` (available in macOS 13+) instead of building raw custom `NSWindowControllers`.
- **Rationale**: Keeps the codebase clean, leverages modern SwiftUI bindings, and integrates natively with the `openWindow` environment action.
- **Triggers**: Open via `⌘,` (Command + Comma) or the standard app menu bar item.

### 2. Non-blocking Background Shader Compilation
- **Decision**: Use the asynchronous `makeLibrary(source:options:completionHandler:)` API from Metal.
- **Rationale**: Synchronous compilation blocks the main thread, causing minor frame drops or freezing the audio capture loop. Asynchronous compilation keeps the rendering continuous while the new shader compiles in the background.

### 3. Unified Metal Dynamic Uniform Structure
- **Decision**: Standardize the data format bound to the dynamic fragment shader at buffer index `0`.
- **Data Blueprint**:
  ```metal
  struct AudioDataUniforms {
      float frequencies[512]; // Real-time FFT frequency bins
      float rawSamples[512];  // Time-domain PCM samples
      float time;             // Elapsed time in seconds
      float2 viewportSize;    // Width and height of the draw surface
  };
  ```

## Risks / Trade-offs

- **[Risk] User enters invalid Metal code causing GPU crashes**
  - *Mitigation*: Validate shader compilation using try-catch blocks over the library generation. If compilation fails, stop the swap, preserve the error log, display it in the settings panel's console tab, and continue running the previous valid shader.
- **[Risk] High memory footprint from compiled shader libraries**
  - *Mitigation*: Explicitly release and deallocate obsolete `MTLLibrary` and `MTLRenderPipelineState` objects during dynamic reloads.
