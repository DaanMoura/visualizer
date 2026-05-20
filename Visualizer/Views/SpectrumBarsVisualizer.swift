import SwiftUI

struct SpectrumBarsVisualizer: View {
    @EnvironmentObject var audioEngine: AudioEngineManager
    
    var body: some View {
        Canvas { context, size in
            let barCount = 32
            let spacing: CGFloat = 8
            let totalSpacing = spacing * CGFloat(barCount - 1)
            let barWidth = (size.width - totalSpacing) / CGFloat(barCount)
            
            guard barWidth > 0 else { return }
            
            // Neon glow filter applied to the entire drawing context
            context.drawLayer { localContext in
                for i in 0..<barCount {
                    let amplitude = CGFloat(audioEngine.amplitudes[i])
                    let peak = CGFloat(audioEngine.peaks[i])
                    
                    let x = CGFloat(i) * (barWidth + spacing)
                    
                    // Constrain max height to leave elegant breathing room at the top
                    let maxHeight = size.height - 40
                    
                    // Draw vertical amplitude bar
                    let barHeight = max(4, amplitude * maxHeight)
                    let barY = size.height - barHeight
                    let barRect = CGRect(x: x, y: barY, width: barWidth, height: barHeight)
                    let barPath = Path(roundedRect: barRect, cornerRadius: min(barWidth / 2, 4))
                    
                    // Modern gradient: Vibrant cyan transitioning to deep magenta
                    let gradient = Gradient(colors: [
                        Color(red: 0.0, green: 0.9, blue: 1.0), // Neon Cyan
                        Color(red: 0.8, green: 0.1, blue: 0.9)  // Vibrant Magenta
                    ])
                    
                    localContext.fill(
                        barPath,
                        with: .linearGradient(
                            gradient,
                            startPoint: CGPoint(x: x, y: size.height),
                            endPoint: CGPoint(x: x, y: barY)
                        )
                    )
                    
                    // Draw floating peak dot
                    let peakY = size.height - (peak * maxHeight) - 6
                    let peakRect = CGRect(x: x, y: peakY, width: barWidth, height: min(barWidth / 2, 4))
                    let peakPath = Path(roundedRect: peakRect, cornerRadius: 2)
                    
                    localContext.fill(
                        peakPath,
                        with: .color(Color(red: 0.3, green: 0.95, blue: 1.0)) // High-luminance neon cyan
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
