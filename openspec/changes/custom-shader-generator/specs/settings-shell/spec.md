## ADDED Requirements

### Requirement: Custom Shader Library Editor
The Settings window SHALL provide a multi-line code editor or text area in the 'Shader Library' tab where users can list, select, view, write, and test custom MSL visualizer shaders. It SHALL also include a compilation console log output to display real-time errors or warnings.

#### Scenario: Activate Custom Shader
- **WHEN** the user selects a custom shader from the list and clicks "Run / Activate"
- **THEN** the system triggers the dynamic visualizer to compile and load the selected shader code.

#### Scenario: Display Compilation Console Output
- **WHEN** a custom shader compilation fails with syntax errors
- **THEN** the Settings window console area automatically updates to display the detailed compiler errors.
