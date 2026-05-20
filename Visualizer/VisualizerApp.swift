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
    }
}
