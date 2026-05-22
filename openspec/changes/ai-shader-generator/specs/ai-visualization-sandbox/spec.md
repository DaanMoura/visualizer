## ADDED Requirements

### Requirement: Dual-Client API Connector
The application SHALL support requesting visualizer MSL shaders from both the OpenRouter API (when an API key is provided) and local Llama/Ollama API endpoints.

#### Scenario: OpenRouter Request Dispatch
- **GIVEN** a valid OpenRouter API key and model selection saved in settings
- **WHEN** the user triggers "Generate with AI"
- **THEN** the system dispatches an HTTP POST request to OpenRouter with proper Authorization headers and a system prompt explaining MSL constraints.

#### Scenario: Local Llama Request Dispatch
- **GIVEN** local model mode is selected in settings
- **WHEN** the user triggers "Generate with AI"
- **THEN** the system dispatches a local HTTP request to `http://localhost:11434/api/generate` or `/api/chat` using the configured model.

---

### Requirement: Dynamic Code Cleaning
The application SHALL parse and strip any Markdown wrappers, prose explanations, or language specifiers (e.g. ` ```metal ` blocks) from the LLM completion response before feeding the source code into the Metal compiler.

---

### Requirement: Compiler Auto-Healing Feedback Loop
The application SHALL support an automated compile feedback loop that detects MSL compiler errors and recursively prompts the LLM to fix syntax errors.

#### Scenario: Dynamic Compilation Success on First Try
- **WHEN** the LLM returns valid MSL code
- **THEN** the compiler compiles it successfully, and the system hot-reloads the visualizer immediately.

#### Scenario: Dynamic Compilation Typos Self-Healed
- **WHEN** the LLM returns MSL code with syntax errors (e.g., missing semicolons)
- **THEN** the dynamic compiler catches the error logs, sends a correction prompt including the error message back to the LLM, and successfully compiles the repaired MSL on the second try.

#### Scenario: Compilation Loop Exhaustion
- **WHEN** the LLM repeatedly returns invalid MSL code across 3 compile-and-fail attempts
- **THEN** the feedback loop halts, terminates further requests, retains the last compiler error output in the console, and leaves the previous active visualizer running.
