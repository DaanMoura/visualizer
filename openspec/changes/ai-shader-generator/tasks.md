## 1. API Client Scaffolding

- [ ] 1.1 Define request and response Decodable/Encodable JSON models matching OpenRouter and Llama schemas
- [ ] 1.2 Implement the dynamic `AIShaderClient.swift` that loads API credentials (OpenRouter key / Llama URL) from `@AppStorage`
- [ ] 1.3 Implement async connection health and verification checks to report API availability in the console

## 2. System Prompts & Response Sanitization

- [ ] 2.1 Construct the core system prompt documenting MSL vertex/fragment function constraints and copying the exact `AudioDataUniforms` structure as comments
- [ ] 2.2 Implement a response sanitizing helper in Swift to strip surrounding triple-backticks, language tags (`metal`, `cpp`), and verbose prose comments
- [ ] 2.3 Add test cases verifying that code strings wrapped in markdown are correctly cleaned and parsed

## 3. Dynamic Self-Healing Compiler Loop

- [ ] 3.1 Expose dynamic compile results (compilation logs and error strings) in the dynamic compiler callback
- [ ] 3.2 Implement a recursive self-healing coordinator that tracks attempts, extracts relevant compiler error lines, and builds the correction prompts
- [ ] 3.3 Set up a hard boundary of max 3 retry attempts to prevent infinite request loops and high token consumption

## 4. UI Settings Integration

- [ ] 4.1 Expand the 'Shader Library' tab in `SettingsView.swift` to add a prompt text input area, active model selection dropdown, and "Generate with AI" button
- [ ] 4.2 Integrate a visual generation loader overlay and dynamic progress logger inside the settings panel
- [ ] 4.3 Lock inputs and editing during active generation runs to prevent state conflicts
- [ ] 4.4 Add the 'API Credentials' sidebar item to the Settings window navigation list, hosting a native form with persistent `@AppStorage` text inputs for OpenRouter API keys and custom local Llama endpoints

## 5. Verification & Testing

- [ ] 5.1 Verify that providing a standard prompt (e.g. "glowing neon circle pulsing to bass") returns valid compiled MSL code
- [ ] 5.2 Verify that network timeouts or missing keys are gracefully handled with clear user-facing alerts
- [ ] 5.3 Test the self-healing compiler loop by injecting a manual syntax warning or error, validating that the correction loop repairs and successfully runs the shader
