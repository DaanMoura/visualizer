# metal-particles Specification

## Purpose
TBD - created by archiving change new-visualisations. Update Purpose after archive.
## Requirements
### Requirement: Metal-Based Particle Vortex Rendering
The application SHALL implement a Metal-based visualizer style that renders a particle system of at least 5,000 particles orbiting the screen. The particle movements, expansion, speed, and turbulence SHALL be computed on the CPU/GPU and rendered in real time using Apple's native Metal framework at a fluid 60+ FPS.

#### Scenario: Particle Rendering with Metal
- **WHEN** the Neon Particle Vortex style is selected and the audio stream is running
- **THEN** a system of thousands of neon glowing particles is rendered on screen using high-performance Metal draw calls.

### Requirement: Audio-Reactive Particle Dynamics
The Metal particle visualizer SHALL scale its particle movements and effects in real-time based on audio amplitudes and frequencies. Particles SHALL react to low frequencies (bass) by expanding outwards, and react to overall RMS levels by increasing orbit velocity.

#### Scenario: Particle Burst on Audio Amplitude Spike
- **WHEN** a high-energy beat or bass frequency spike is detected in the audio stream
- **THEN** the particles expand outwards in a vibrant burst, matching the intensity of the audio signal.

