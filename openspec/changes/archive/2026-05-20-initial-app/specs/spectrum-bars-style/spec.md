## ADDED Requirements

### Requirement: Spectrum Bars Rendering
The system SHALL render the analyzed frequency bands as vertical, glowing, gradient-filled bars using a high-performance SwiftUI Canvas or custom graphic rendering context at 60+ FPS.

#### Scenario: Active Render
- **WHEN** frequency bin values are updated
- **THEN** the system redraws the spectrum bars with height proportional to each frequency band's amplitude.

### Requirement: Peak Fall Physics
Each spectrum bar SHALL feature a floating peak indicator dot at its highest reached level. When the amplitude drops, the peak indicator SHALL pause briefly (hang time) and then fall smoothly under linear or exponential gravity decay.

#### Scenario: Peak Drop Animation
- **WHEN** the amplitude of a frequency band decreases
- **THEN** its peak indicator dot hovers briefly before falling smoothly down to the current level of the spectrum bar.

### Requirement: Layout Adaptation
The visualizer layout (bar widths, gaps, and scale) SHALL automatically adapt to window dimension changes and fullscreen toggles dynamically, without restarting the audio capture stream or losing rendering state.

#### Scenario: Window Resized Fluidly
- **WHEN** the user resizes the window or toggles fullscreen
- **THEN** the spectrum bars re-layout dynamically to fill the available canvas width and height without dropping frames or interrupting audio capture.
