# visualizer-swapping Specification

## Purpose
TBD - created by archiving change new-visualisations. Update Purpose after archive.
## Requirements
### Requirement: Menu Bar Visualizer Selection
The application SHALL display a menu item or submenu in the macOS native menu bar containing all available visualizer styles. Selecting a style from the menu SHALL instantly switch the active visualizer to the chosen style without interrupting or restarting the audio capture engine.

#### Scenario: Select Visualizer from Menu Bar
- **WHEN** the user selects a visualizer style from the menu bar
- **THEN** the active visualizer transitions instantly to the selected style while the audio capture continues uninterrupted.

### Requirement: Keyboard Arrow Navigation
The application SHALL support navigating between visualizer styles using the keyboard's Left Arrow and Right Arrow keys. Pressing the Left Arrow key SHALL cycle to the previous visualizer style, and pressing the Right Arrow key SHALL cycle to the next visualizer style. The cycling SHALL wrap around when reaching either end of the list of styles. Standard system warning beeps SHALL be suppressed during this navigation.

#### Scenario: Navigate to Next Visualizer
- **WHEN** the user presses the Right Arrow key on the keyboard
- **THEN** the active visualizer cycles to the next style in the list, wrapping around if the end is reached, without interrupting the audio stream.

#### Scenario: Navigate to Previous Visualizer
- **WHEN** the user presses the Left Arrow key on the keyboard
- **THEN** the active visualizer cycles to the previous style in the list, wrapping around if the beginning is reached, without interrupting the audio stream.

