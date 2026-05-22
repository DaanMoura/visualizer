## ADDED Requirements

### Requirement: Active Visualizer Rendering Host
The visualization view SHALL host the currently active visualizer style, supplying it with real-time frequency-domain and/or time-domain PCM data. Swapping the active style SHALL instantly update the rendering view to the new style.

#### Scenario: Display Active Visualizer Style
- **WHEN** a visualizer style is selected as active
- **THEN** the visualization surface hosts and renders that specific style using real-time audio data.
