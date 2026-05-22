# vortex-renderer Specification

## Purpose
TBD - created by archiving change new-visualisations. Update Purpose after archive.
## Requirements
### Requirement: Frequency Vortex Rendering
The application SHALL implement a Frequency Vortex visualizer style that renders frequency-domain data as radial elements extending outwards from the center of the screen. These elements SHALL scale in size and rotate dynamically based on real-time FFT frequency amplitudes.

#### Scenario: Frequency Vortex Scaling and Rotation
- **WHEN** the Frequency Vortex style is selected and the audio stream is running
- **THEN** the screen renders radial lines expanding and rotating dynamically in sync with the audio's frequency-domain data.

