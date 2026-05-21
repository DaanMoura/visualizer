import SwiftUI

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
            AudioInputCommands(audioEngine: audioEngine)
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
