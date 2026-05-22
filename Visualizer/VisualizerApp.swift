import SwiftUI
import AVFoundation
import CoreAudio

@main
struct VisualizerApp: App {
    @StateObject private var audioEngine = AudioEngineManager()
    
    var body: some Scene {
        WindowGroup {
            VisualizerView()
                .environmentObject(audioEngine)
                .frame(minWidth: 600, minHeight: 400)
                .background(Color.black)
        }
        .windowStyle(.hiddenTitleBar) // Hides title bar for standard modern floating visualizer look
        .commands {
            ApplicationSettingsCommands()
            AudioInputCommands(audioEngine: audioEngine)
            VisualizerStyleCommands(audioEngine: audioEngine)
        }
        
        Window("Settings", id: "settings") {
            SettingsView()
                .environmentObject(audioEngine)
        }
        .windowResizability(.contentSize)
    }
}

struct ApplicationSettingsCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("Settings...") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
}

struct AudioInputCommands: Commands {
    @ObservedObject var audioEngine: AudioEngineManager

    var body: some Commands {
        CommandMenu("Audio Input") {
            Button {
                audioEngine.switchCaptureSource(.microphone)
            } label: {
                Label("Microphone / Input Device", systemImage: audioEngine.captureSource == .microphone ? "checkmark" : "circle")
            }

            Button {
                audioEngine.switchCaptureSource(.systemAudio)
            } label: {
                Label("System Audio (Internal)", systemImage: audioEngine.captureSource == .systemAudio ? "checkmark" : "circle")
            }

            Divider()

            Button("Refresh Inputs") {
                audioEngine.refreshInputDevices()
            }
            .disabled(audioEngine.captureSource != .microphone)

            Divider()

            if audioEngine.availableInputDevices.isEmpty {
                Text("No Input Devices Found")
            } else {
                ForEach(audioEngine.availableInputDevices) { device in
                    Button {
                        audioEngine.selectInputDevice(device)
                    } label: {
                        Label(device.name, systemImage: selectedSystemImage(for: device))
                    }
                    .disabled(audioEngine.captureSource != .microphone)
                }
            }
        }
    }

    private func selectedSystemImage(for device: AudioEngineManager.InputDevice) -> String {
        (audioEngine.captureSource == .microphone && audioEngine.selectedInputDevice?.id == device.id) ? "checkmark" : "circle"
    }
}

struct VisualizerStyleCommands: Commands {
    @ObservedObject var audioEngine: AudioEngineManager

    var body: some Commands {
        CommandMenu("Visualisation") {
            Button {
                audioEngine.currentStyle = .spectrumBars
            } label: {
                Label("Spectrum Bars", systemImage: audioEngine.currentStyle == .spectrumBars ? "checkmark" : "circle")
            }
            .keyboardShortcut("1", modifiers: .command)

            Button {
                audioEngine.currentStyle = .oscilloscope
            } label: {
                Label("Oscilloscope Wave", systemImage: audioEngine.currentStyle == .oscilloscope ? "checkmark" : "circle")
            }
            .keyboardShortcut("2", modifiers: .command)

            Button {
                audioEngine.currentStyle = .frequencyVortex
            } label: {
                Label("Frequency Vortex", systemImage: audioEngine.currentStyle == .frequencyVortex ? "checkmark" : "circle")
            }
            .keyboardShortcut("3", modifiers: .command)

            Button {
                audioEngine.currentStyle = .metalParticles
            } label: {
                Label("Neon Particle Vortex (Metal)", systemImage: audioEngine.currentStyle == .metalParticles ? "checkmark" : "circle")
            }
            .keyboardShortcut("4", modifiers: .command)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var audioEngine: AudioEngineManager
    
    enum SidebarItem: String, CaseIterable, Identifiable {
        case audio = "Audio"
        case shaderLibrary = "Shader Library"
        
        var id: String { rawValue }
        
        var systemImage: String {
            switch self {
            case .audio: return "waveform"
            case .shaderLibrary: return "square.stack.3d.up"
            }
        }
    }
    
    @State private var selectedItem: SidebarItem? = .audio
    
    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selectedItem) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.systemImage)
                        .padding(.vertical, 2)
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 160, ideal: 180, max: 240)
        } detail: {
            if let selectedItem = selectedItem {
                switch selectedItem {
                case .audio:
                    AudioSettingsView()
                        .environmentObject(audioEngine)
                case .shaderLibrary:
                    ShaderLibraryPlaceholderView()
                }
            } else {
                Text("Select an item")
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 550, idealWidth: 600, minHeight: 380, idealHeight: 440)
    }
}

struct AudioSettingsView: View {
    @EnvironmentObject var audioEngine: AudioEngineManager
    
    var body: some View {
        Form {
            Section(header: Text("Capture Options")) {
                Picker("Capture Source", selection: Binding(
                    get: { audioEngine.captureSource },
                    set: { newSource in
                        audioEngine.switchCaptureSource(newSource)
                    }
                )) {
                    ForEach(AudioEngineManager.CaptureSource.allCases) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.vertical, 4)
            }
            
            if audioEngine.captureSource == .microphone {
                Section(header: Text("Microphone Device")) {
                    if audioEngine.permissionState == .denied {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Microphone permission has been denied. Please enable it in System Settings.")
                                .font(.footnote)
                        }
                        .padding(.vertical, 4)
                    } else if audioEngine.permissionState == .undetermined {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Microphone access is required to visualize microphone input.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Button("Request Permission") {
                                audioEngine.requestPermission()
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        if audioEngine.availableInputDevices.isEmpty {
                            Text("No Audio Input Devices Found")
                                .foregroundColor(.secondary)
                        } else {
                            Picker("Input Device", selection: Binding(
                                get: { audioEngine.selectedInputDevice?.id ?? AudioObjectID(kAudioObjectUnknown) },
                                set: { newId in
                                    if let device = audioEngine.availableInputDevices.first(where: { $0.id == newId }) {
                                        audioEngine.selectInputDevice(device)
                                    }
                                }
                            )) {
                                ForEach(audioEngine.availableInputDevices) { device in
                                    Text(device.name).tag(device.id)
                                }
                            }
                        }
                        
                        Button(action: {
                            audioEngine.refreshInputDevices()
                        }) {
                            Label("Refresh Input Devices", systemImage: "arrow.clockwise")
                        }
                    }
                }
            } else {
                Section(header: Text("System Audio Capture")) {
                    if audioEngine.screenCapturePermissionState == .denied {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Screen/Audio capture permission denied. Please allow Visualizer in System Settings.")
                                .font(.footnote)
                        }
                        .padding(.vertical, 4)
                    } else if audioEngine.screenCapturePermissionState == .undetermined {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("System Audio capture requires Screen Recording permission on macOS.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Button("Request Screen Recording Access") {
                                audioEngine.requestScreenCapturePermission()
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("System capture active via ScreenCaptureKit.")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                            }
                            Text("Captures all internal audio outputs natively. Enjoy standard system-wide visualizer sync.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Audio Settings")
    }
}

struct ShaderLibraryPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "square.stack.3d.up.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("Shader Library")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("In Phase 2, this panel will let you manage, edit, and compile custom Metal Shading Language (MSL) visualization shaders in real-time.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .padding(.vertical, 40)
        .navigationTitle("Shader Library")
    }
}
