## Context

The macOS Sound Visualizer features high-performance rendering. To let the user create custom visualizer styles natively, we need to implement a runtime sandbox. This sandbox will compile and execute user-defined Metal Shading Language (MSL) code on-the-fly.

This change designs the Dynamic Metal compiler, uniform audio buffers binding, and the custom code editor panel in the Settings window.

## Goals / Non-Goals

**Goals:**
- **Dynamic Compilation Engine**: Real-time MSL compilation at runtime using `MTLDevice.makeLibrary(source:options:completionHandler:)`.
- **Audio-Uniform Pipeline**: Feed raw time-domain PCM samples and 512 FFT frequency bins directly into dynamic fragment shaders on every frame.
- **Fail-Safe Compiler Error Handling**: Gracefully catch and report compiler errors and warnings in the settings console output without freezing or crashing the application.
- **Interactive UI Editor Panel**: Host a multiline text editor and active custom shader manager in the 'Shader Library' settings pane.

**Non-Goals:**
- **AI Integrations (Phase 3)**: API clients (OpenRouter, Llama), network triggers, prompt engineering, and prompt self-healing are out of scope.

## Decisions

### 1. Asynchronous Metal Compiler Pipeline
- **Decision**: Use `makeLibrary(source:options:completionHandler:)` from Metal.
- **Rationale**: Shader compilation can be computationally heavy. Running it asynchronously prevents frame drops in the active rendering window and keeps the audio capture tap running smoothly.
- **Error Propagation**: On success, standard `MTLRenderPipelineState` objects are generated and hot-swapped into the sandbox renderer. On failure, the compilation error string is caught, parsed, and updated in the settings console.

### 2. Standarized Shader Bindings
- **Decision**: Define a static `AudioDataUniforms` structure that is copied to fragment buffer index `0` on every frame draw.
- **Uniform Definition**:
  ```metal
  struct AudioDataUniforms {
      float frequencies[512]; // Real-time FFT frequency bins
      float rawSamples[512];  // Time-domain PCM samples
      float time;             // Elapsed time in seconds
      float2 viewportSize;    // Width and height of the canvas
  };
  ```

### 3. Integrated Compiler Console Pane
- **Decision**: Embed a dedicated read-only console pane at the bottom of the 'Shader Library' editor tab in the Settings window.
- **Rationale**: Provides instant visual feedback to the user when testing their own code, ensuring they know exactly what syntax errors or warnings occurred.

## Risks / Trade-offs

- **[Risk] Heavy resource allocation from repeated dynamic pipeline compiles**
  - *Mitigation*: Ensure that obsolete pipeline states, libraries, and functions are explicitly released and nilled out during hot-swaps to prevent GPU memory bloat.
