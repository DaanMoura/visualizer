## Why

Currently, switching audio input sources relies on system menu bar items, and there is no way for users to expand the application's visualizer selection. To retain the zero-HUD main window aesthetic while adding advanced features like customizable, AI-generated, and local-model-supported visualizers, we need a dedicated native configuration window and a dynamic runtime rendering engine.

This change introduces a native Settings/Config window and a dynamic runtime compiler to enable user-defined or AI-designed visualizers without breaking the clean, distraction-free main interface.

## What Changes

- **No Main HUD**: Main window remains strictly minimal, dedicating 100% of its screen real-estate to rendering visualizers.
- **Native Settings/Config Window**: A separate macOS utility window (`SettingsView`/`NSWindow`) to configure:
  - Audio Capture (Input Device and Capture Source picker).
  - API Credentials (OpenRouter API keys and Local Llama connection endpoints).
  - Custom Visualizer Editor (managing and writing custom Metal shader configurations).
- **Runtime Shader Compilation**: Dynamic compiling of Metal Shading Language (MSL) source code at runtime using `device.makeLibrary(source:options:)`, feeding real-time FFT frequency bins and time-domain PCM samples into custom shaders for dynamic, high-performance visualization.
- **Visualizer Style Selection**: Integration of a new `Dynamic Canvas / Shader` case in `VisualizerStyle`.

## Capabilities

### New Capabilities
- `dynamic-visualizer-sandbox`: Runtime compilation of MSL shaders, feeding real-time audio FFT/time-domain data into uniform buffers for dynamic drawing.
- `settings-shell`: Native secondary window hosting settings (audio inputs, API provider credentials, custom visualizer library/management).

### Modified Capabilities
- `visualizer-core`: Update to add a new visualizer case and coordinate with the native secondary settings window.

## Impact

- **AudioEngineManager**: Expand to handle state for the newly selected dynamic visualizers and global API provider settings.
- **VisualizerApp**: Register and handle the lifecycle of the auxiliary Settings/Config window.
- **Metal Integration**: Modify drawing pipelines to support on-the-fly compilation of vertex and fragment shaders.
