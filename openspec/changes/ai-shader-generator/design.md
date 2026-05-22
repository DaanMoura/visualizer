## Context

The macOS Sound Visualizer features a dynamic MSL rendering sandbox. To allow users to create graphics through natural language, we need to design a highly resilient AI pipeline. This pipeline must handle raw network requests, isolate syntax issues, and recursively request corrections from the LLM until the code compiles.

## Goals / Non-Goals

**Goals:**
- **Dual API Clients**: Native support for OpenRouter (API keys, custom cloud models) and Ollama (local Llama `localhost:11434` endpoints).
- **Intelligent Prompt Injection**: Inject strict system prompts, MSL boilerplate headers, and documentation of the `AudioDataUniforms` structure to guide the model.
- **Auto-Healing Compiler Loop**: Intercept raw dynamic compiler error outputs, package them into correction prompts, and run feedback cycles (max 3 retries).
- **Asynchronous UI Execution**: Execute all API roundtrips and compilation checks in background queues using modern Swift structured concurrency (`async/await`, `Task`).

**Non-Goals:**
- **Web App / Server Backend**: No secondary Node.js or Python backend servers. All API connections are executed directly from the macOS Swift client.

## Decisions

### 1. Robust System Prompt & MSL Skeleton Code Injection
- **Decision**: Inject a detailed system prompt that forces the model to return **only** raw MSL shader source code, stripping markdown wrappers if returned.
- **AudioDataUniforms Injection**: The prompt MUST explicitly document the exact uniform struct layout:
  ```metal
  struct AudioDataUniforms {
      float frequencies[512];
      float rawSamples[512];
      float time;
      float2 viewportSize;
  };
  ```
- **MSL Skeleton Template**: Include a preset template (vertex function, rasterizer structs, and standard imports) so the model only needs to construct the fragment function.

### 2. Auto-Healing Compiler State Machine
- **Decision**: Implement a recursive compiler feedback loop.
- **Workflow**:
  ```
   User Prompt ──> Call LLM API ──> Strip MD Code Block ──> MSL Compiler 
                                                                │
           ┌────────────────────────────────────────────────────┘
           ▼
     [Compile Result]
           ├──> SUCCESS ──> Apply Hot-Reload (Atomically swap pipeline state)
           └──> FAILURE (Attempts < 3) ──> Extract Error Log 
                                                   │
                                                   ▼
                                         Build Correction Prompt ──> Retry LLM
  ```
- **Rationale**: Shaders are highly syntax-sensitive. Simple typos (like missing semi-colons or incorrect vector constructors) can easily happen. A 3-cycle auto-healing loop raises generation success rates significantly.

### 3. Swift Concurrency & Network Safety
- **Decision**: Utilize `URLSession.shared.data(for:)` within `async/await` contexts.
- **Rationale**: Keeps the rendering canvas fluid at 60+ FPS while network API calls await.
- **Timeout Management**: Configure a strict 15-second network timeout. If reached, fail gracefully and display a connection error.

## Risks / Trade-offs

- **[Risk] Model returning verbose markdown explanations or empty code blocks**
  - *Mitigation*: Regex-based cleaning code to strip any pre- or post-text, extracting only content between triple-backticks ` ```metal ` or ` ```clike ` or ` ``` `.
- **[Risk] Heavy token usage in recursive error corrections**
  - *Mitigation*: Keep error logs concise by feeding only relevant compiler error lines back to the model rather than the full multi-page diagnostic dump.
