import SwiftUI

struct PermissionWarningView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(.orange)
                .shadow(color: .orange.opacity(0.4), radius: 8)
            
            VStack(spacing: 8) {
                Text("Microphone Permission Required")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Sound Visualizer needs access to your default audio input device to analyze audio and render graphs.")
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
                    Text("Navigate to **Privacy & Security** > **Microphone**.")
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
                            .fill(Color.orange)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(30)
    }
    
    private func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
            NSWorkspace.shared.open(url)
        } else if let url = URL(string: "x-apple.systempreferences:") {
            NSWorkspace.shared.open(url)
        }
    }
}
