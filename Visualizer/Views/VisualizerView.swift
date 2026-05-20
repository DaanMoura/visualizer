import SwiftUI
import AppKit

struct VisualizerView: View {
    @EnvironmentObject var audioEngine: AudioEngineManager
    @State private var keyMonitor: Any? = nil
    
    var body: some View {
        Group {
            switch audioEngine.permissionState {
            case .undetermined:
                RequestPermissionView()
            case .denied:
                PermissionWarningView()
            case .granted:
                ActiveVisualizerContainer()
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
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("Sound Visualizer")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("To visualize your sound in real-time, please grant microphone/input permissions.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }
            
            Button(action: {
                audioEngine.requestPermission()
            }) {
                Text("Grant Permission")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                    )
            }
            .buttonStyle(.plain)
            
            Text("Tip: Install a loopback driver like BlackHole to visualize pure internal computer sound.")
                .font(.system(size: 11))
                .foregroundColor(.darkGray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
    }
}

struct ActiveVisualizerContainer: View {
    @EnvironmentObject var audioEngine: AudioEngineManager
    @State private var showDiagnostics = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top HUD Overlay
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(audioEngine.isAudioActive ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(audioEngine.isAudioActive ? "LIVE" : "OFFLINE")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(audioEngine.isAudioActive ? .green.opacity(0.8) : .red.opacity(0.8))
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showDiagnostics.toggle()
                        }
                    }
                    
                    Spacer()
                    
                    Text(showDiagnostics ? "Click 'LIVE' to hide diagnostics | F: Fullscreen" : "Click 'LIVE' for diagnostics | F: Fullscreen")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                }
                
                if showDiagnostics && audioEngine.isAudioActive {
                    HStack(spacing: 12) {
                        Text("Device: \(audioEngine.activeDeviceName)")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Text("Signal:")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                            
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 50, height: 4)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.cyan, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 50 * CGFloat(min(1.0, max(0.0, audioEngine.rmsLevel * 10.0))), height: 4)
                            }
                            
                            let dbVal = audioEngine.rmsLevel > 1e-5 ? 20.0 * log10(audioEngine.rmsLevel) : -100.0
                            Text(String(format: "%.1f dB", dbVal))
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(audioEngine.rmsLevel > 0.001 ? .green.opacity(0.8) : .white.opacity(0.3))
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Core Visualizer View
            SpectrumBarsVisualizer()
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            toggleFullscreen()
                        }
                )
        }
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
