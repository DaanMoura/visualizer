## Why

To allow users to expand the application's visualizer selections dynamically, we need to create a runtime environment that compiles and renders user-defined graphics scripts on-the-fly. Using standard macOS Xcode-compiled shaders restricts users to hardcoded styles. 

This change introduces a dynamic rendering sandbox using the Metal API, enabling on-the-fly compiling of custom Metal Shading Language (MSL) visualizer code directly within the app, complete with real-time audio FFT/time-domain inputs.

## What Changes

- **Dynamic Visualizer Case**: Add a `.dynamicShader` style selection to the `VisualizerStyle` enum, supported by a dynamic `ActiveVisualizerContainer` render surface.
- **Metal Sandbox Renderer**: Implement `DynamicMetalVisualizer` containing an `MTKView` that dynamically compiles and binds fragment shaders.
- **Real-time Audio Uniform Binding**: Copy 512 FFT frequency bins and raw time-domain PCM samples into custom fragment shaders on every frame.
- **Interactive Shader Editor**: Implement a multi-line code editor pane inside the 'Shader Library' settings tab, complete with a dynamic console log that outputs compiler warning and syntax errors natively.

## Capabilities

### New Capabilities
- `dynamic-visualizer-sandbox`: Runtime MSL compilation using non-blocking background threads, binding standard audio structures (`AudioDataUniforms`) to fragment index 0.

### Modified Capabilities
- `settings-shell`: Expand settings layout to replace the Shader Library tab placeholder with the active code editor, custom list, run control, and compiler console.

## Impact

- **AudioEngineManager**: Expand state to track the active dynamic shader code, custom visualizer array, and compiler output logs.
- **DynamicMetalVisualizer**: Native MTKView drawing context that compilable on-the-fly.
- **SettingsView**: Host the custom shader editor UI, active script launcher, and dynamic output console.
