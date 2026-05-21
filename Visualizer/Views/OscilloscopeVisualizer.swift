import SwiftUI

struct OscilloscopeVisualizer: View {
    @EnvironmentObject var audioEngine: AudioEngineManager

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let midY = height / 2
                
                let samples = audioEngine.rawSamples
                let count = samples.count
                
                guard count > 0 else { return }
                
                var path = Path()
                
                for i in 0..<count {
                    let x = CGFloat(i) / CGFloat(count - 1) * width
                    // Multiply sample to ensure full-range visual movement, adding responsive scale
                    let sample = samples[i]
                    let y = midY + CGFloat(sample) * midY * 1.3
                    
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                // Draw a beautiful neon glow behind the wave
                var glowContext = context
                glowContext.addFilter(.blur(radius: 8))
                glowContext.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [.cyan.opacity(0.8), .pink.opacity(0.8)]),
                        startPoint: CGPoint(x: 0, y: midY),
                        endPoint: CGPoint(x: width, y: midY)
                    ),
                    lineWidth: 6
                )
                
                // Draw the bright, sharp wave foreground layer
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [.white, .cyan, .pink]),
                        startPoint: CGPoint(x: 0, y: midY),
                        endPoint: CGPoint(x: width, y: midY)
                    ),
                    lineWidth: 2.5
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
