## ADDED Requirements

### Requirement: Dynamic Shader Compilation
The application SHALL support compiling Metal Shading Language (MSL) source code at runtime from a raw string. If the shader compilation is successful, it SHALL instantly hot-reload the rendering pipeline with the new shader. If compilation fails, it SHALL capture and retain the build errors to display to the user.

#### Scenario: Successful Shader Hot-Reload
- **WHEN** a valid MSL shader string is loaded into the dynamic visualizer engine
- **THEN** the engine compiles the shader on-the-fly and immediately starts rendering using the new pipeline without restarting audio taps or dropping existing audio frames.

#### Scenario: Shader Compilation Failure
- **WHEN** an invalid MSL shader string containing syntax errors is loaded
- **THEN** the compiler fails gracefully, retains the error log, and leaves the previous active visualizer running or displays a clean fallback/error state.

### Requirement: Real-time Audio Data Uniform Feeding
The dynamic visualizer shader SHALL receive real-time audio FFT frequency bins and raw time-domain PCM samples. The system SHALL copy these values into Metal constant buffers or uniform parameters on every frame update.

#### Scenario: Render Frame Audio Data Copy
- **WHEN** a new frame is drawn by the MTKView for the dynamic visualizer
- **THEN** the system packages the current 512 frequency bins and raw time-domain audio samples into a constant buffer and binds it to the fragment shader.
