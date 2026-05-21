import SwiftUI

struct PermissionWarningView: View {
    @EnvironmentObject var audioEngine: AudioEngineManager
    let source: AudioEngineManager.CaptureSource
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(source == .microphone ? .orange : .purple)
                .shadow(color: (source == .microphone ? Color.orange : Color.purple).opacity(0.4), radius: 8)
            
            VStack(spacing: 8) {
                Text(source == .microphone ? "Microphone Permission Required" : "Screen Recording Permission Required")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(source == .microphone 
                     ? "Sound Visualizer needs access to your default audio input device to analyze audio and render graphs."
                     : "Sound Visualizer needs screen recording/capture access to grab system speaker output for analysis.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    Text("1.")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.cyan)
                    Text("Open **System Settings** on your Mac.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Text("2.")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.cyan)
                    Text(source == .microphone 
                         ? "Navigate to **Privacy & Security** > **Microphone**."
                         : "Navigate to **Privacy & Security** > **Screen & System Audio Recording**.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Text("3.")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.cyan)
                    Text("Enable the switch next to **Visualizer**.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
            .frame(maxWidth: 340)
            
            Button(action: {
                openSystemSettings()
            }) {
                Text("Open Privacy Settings")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(source == .microphone ? Color.orange : Color.purple)
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
        }
        .padding(30)
    }
    
    private func openSystemSettings() {
        let path = source == .microphone ? "Privacy_Microphone" : "Privacy_ScreenCapture"
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?\(path)") {
            NSWorkspace.shared.open(url)
        } else if let url = URL(string: "x-apple.systempreferences:") {
            NSWorkspace.shared.open(url)
        }
    }
}
