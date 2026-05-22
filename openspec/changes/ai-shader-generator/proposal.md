## Why

Writing custom Metal Shading Language (MSL) visualizer code is a barrier for users who do not have graphic programming experience. To fulfill our vision of a highly customisable, distraction-free visualizer experience, we need to empower users to generate spectacular graphics using natural language prompts.

This change introduces an AI-powered visualizer generation subsystem that leverages either external cloud LLMs (via OpenRouter APIs like Claude 3.5 Sonnet or GPT-4o) or local offline models (via Ollama/Llama) to produce clean MSL code dynamically, hot-compiles it in the sandbox, and includes an intelligent auto-healing compiler loop.

## What Changes

- **AI Prompt Console**: Add a natural-language prompt input field and a "Generate with AI" button within the 'Shader Library' tab in the Settings window.
- **Dual API Client Integrations**:
  - **OpenRouter Client**: A robust API client that connects securely to the OpenRouter endpoint utilizing `@AppStorage` API credentials.
  - **Local Llama (Ollama) Client**: A lightweight, offline-ready client that connects to local host endpoints (`http://localhost:11434/api/generate` or `/api/chat`).
- **Dynamic Self-Healing Compiler Loop**:
  - Implement a feedback loop that monitors compiler success. 
  - If a generated MSL shader fails compilation, the system automatically captures the exact compiler syntax logs and warning messages, builds a targeted correction prompt, and sends it back to the active model for up to 3 repair attempts.
- **UI Progress states**: Incorporate smooth loading overlays, generating indicators, and step-by-step progress status logs ("Connecting to AI...", "Compiling MSL...", "Error caught, self-healing...", "Visualizer Ready!").

## Capabilities

### New Capabilities
- `ai-visualization-generator`: Multi-client API connectors, structured prompt packaging (injecting MSL templates and `AudioDataUniforms` structures), loading state machines, and recursive self-healing compilers.

### Modified Capabilities
- `settings-shell`: Expand the Shader Library tab to include prompt input controls, model selection toggles, generator triggers, and status panels alongside the code editor.

## Impact

- **AudioEngineManager**: Add state parameters tracking the active prompt text, generation progress logs, and connection status.
- **SettingsView**: Integrate prompt inputs, model selectors, loading wheels, and connection checkers.
