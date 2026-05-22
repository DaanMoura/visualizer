## ADDED Requirements

### Requirement: Settings Window Auxiliary Launch
The application SHALL support opening a separate native macOS Settings window. This window SHALL be opened via the system menu bar item or the standard `⌘,` keyboard shortcut, leaving the main visualizer window entirely distraction-free.

#### Scenario: Open Settings Window via Menu Item
- **WHEN** the user selects "Settings..." from the application menu or presses `⌘,` (Command + Comma)
- **THEN** a separate native macOS settings window is spawned or brought to the foreground containing all configurations, while the main visualizer window continues rendering its visualization surface uninterrupted.
