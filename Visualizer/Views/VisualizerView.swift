import SwiftUI
import AppKit

struct VisualizerView: View {
    @EnvironmentObject var audioEngine: AudioEngineManager
    @State private var keyMonitor: Any? = nil

    var body: some View {
        Group {
            if audioEngine.captureSource == .microphone {
                switch audioEngine.permissionState {
                case .undetermined:
                    RequestPermissionView(source: .microphone)
                case .denied:
                    PermissionWarningView(source: .microphone)
                case .granted:
                    ActiveVisualizerContainer()
                }
            } else {
                switch audioEngine.screenCapturePermissionState {
                case .undetermined:
                    RequestPermissionView(source: .systemAudio)
                case .denied:
                    PermissionWarningView(source: .systemAudio)
                case .granted:
                    ActiveVisualizerContainer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.03, green: 0.03, blue: 0.05)) // Aesthetic modern dark slate
        .onAppear {
            setupKeyboardMonitor()
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
    }

    private func setupKeyboardMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Check if key is F or f
            if let chars = event.charactersIgnoringModifiers, chars.lowercased() == "f" {
                toggleFullscreen()
                return nil // Event is handled, suppress propagation
            }
            
            // Intercept Left and Right arrow keys to switch visualizer style
            if event.keyCode == 123 { // Left Arrow
                audioEngine.previousStyle()
                return nil // Event is handled, suppress propagation and beep
            } else if event.keyCode == 124 { // Right Arrow
                audioEngine.nextStyle()
                return nil // Event is handled, suppress propagation and beep
            }
            
            return event
        }
    }

    private func removeKeyboardMonitor() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }

    private func toggleFullscreen() {
        DispatchQueue.main.async {
            // Find our active window and toggle fullscreen
            if let window = NSApplication.shared.windows.first(where: { $0.isVisible && $0.className.contains("Window") }) {
                window.toggleFullScreen(nil)
            }
        }
    }
}

struct RequestPermissionView: View {
    @EnvironmentObject var audioEngine: AudioEngineManager
    let source: AudioEngineManager.CaptureSource

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: source == .microphone ? "waveform.circle.fill" : "desktopcomputer")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: source == .microphone ? [.cyan, .purple] : [.orange, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                Text(source == .microphone ? "Sound Visualizer" : "System Audio Capture")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(source == .microphone 
                     ? "To visualize your sound in real-time, please grant microphone/input permissions."
                     : "To visualize your system's speaker output natively, please grant screen capture permissions.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }

            Button(action: {
                if source == .microphone {
                    audioEngine.requestPermission()
                } else {
                    audioEngine.requestScreenCapturePermission()
                }
            }) {
                Text(source == .microphone ? "Grant Permission" : "Grant System Audio Permission")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                colors: source == .microphone ? [.blue, .cyan] : [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
            }
            .buttonStyle(.plain)

            Button(action: {
                audioEngine.switchCaptureSource(source == .microphone ? .systemAudio : .microphone)
            }) {
                Text(source == .microphone ? "Switch to System Audio" : "Switch to Microphone Input")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.cyan)
                    .underline()
            }
            .buttonStyle(.plain)

            Text(source == .microphone 
                 ? "Tip: Install a loopback driver like BlackHole to visualize pure internal computer sound."
                 : "Tip: ScreenCaptureKit requires Screen Recording permission to tap speaker output. No video is recorded or stored.")
                .font(.system(size: 11))
                .foregroundColor(.darkGray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
    }
}

struct ActiveVisualizerContainer: View {
    @EnvironmentObject var audioEngine: AudioEngineManager

    var body: some View {
        Group {
            switch audioEngine.currentStyle {
            case .spectrumBars:
                SpectrumBarsVisualizer()
            case .oscilloscope:
                OscilloscopeVisualizer()
            case .frequencyVortex:
                FrequencyVortexVisualizer()
            case .metalParticles:
                MetalParticleVisualizer()
            }
        }
        .gesture(
            TapGesture(count: 2)
                .onEnded {
                    toggleFullscreen()
                }
        )
    }

    private func toggleFullscreen() {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first(where: { $0.isVisible && $0.className.contains("Window") }) {
                window.toggleFullScreen(nil)
            }
        }
    }
}

extension Color {
    static let darkGray = Color(red: 0.4, green: 0.4, blue: 0.45)
}
