import SwiftUI

struct FrequencyVortexVisualizer: View {
    @EnvironmentObject var audioEngine: AudioEngineManager

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let center = CGPoint(x: width / 2, y: height / 2)
                
                let currentTime = timeline.date.timeIntervalSince1970
                
                // Calculate dynamic time-based rotation, accelerating when bass energy (RMS) is active
                let baseRotation = currentTime * 0.45 + Double(audioEngine.rmsLevel) * 0.65
                
                let bands = 32
                let minRadius = min(width, height) * 0.16
                let maxExtend = min(width, height) * 0.32
                
                // 1. Draw glowing neon radial ambient light background
                let glowRadius = minRadius + CGFloat(audioEngine.rmsLevel) * maxExtend * 0.4
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: center.x - glowRadius,
                        y: center.y - glowRadius,
                        width: glowRadius * 2,
                        height: glowRadius * 2
                    )),
                    with: .radialGradient(
                        Gradient(colors: [.purple.opacity(0.12), .clear]),
                        center: center,
                        startRadius: 0,
                        endRadius: glowRadius
                    )
                )

                // 2. Draw 32 frequency-domain radial bars
                for i in 0..<bands {
                    let amplitude = audioEngine.amplitudes[i]
                    let peak = audioEngine.peaks[i]
                    
                    // Distribute bars uniformly around the circle
                    let angle = (Double(i) / Double(bands)) * 2 * .pi + baseRotation
                    let cosAngle = CGFloat(cos(angle))
                    let sinAngle = CGFloat(sin(angle))
                    
                    let startPt = CGPoint(
                        x: center.x + minRadius * cosAngle,
                        y: center.y + minRadius * sinAngle
                    )
                    
                    let endRadius = minRadius + CGFloat(amplitude) * maxExtend
                    let endPt = CGPoint(
                        x: center.x + endRadius * cosAngle,
                        y: center.y + endRadius * sinAngle
                    )
                    
                    // Premium Hue shifts: Cyan (190 deg) -> Pink/Magenta (300 deg)
                    let t = Double(i) / Double(bands - 1)
                    let hue = 0.527 + t * 0.305
                    let color = Color(hue: hue, saturation: 0.92, brightness: 1.0)
                    
                    var path = Path()
                    path.move(to: startPt)
                    path.addLine(to: endPt)
                    
                    // Draw neon blur layer
                    var glowContext = context
                    glowContext.addFilter(.blur(radius: 6))
                    glowContext.stroke(
                        path,
                        with: .color(color.opacity(0.35)),
                        lineWidth: 6
                    )
                    
                    // Draw sharp foreground layer
                    context.stroke(
                        path,
                        with: .color(color),
                        lineWidth: 3
                    )
                    
                    // 3. Draw radial falling peak dots
                    if peak > 0.02 {
                        let peakRadius = minRadius + CGFloat(peak) * maxExtend + 4
                        let peakPt = CGPoint(
                            x: center.x + peakRadius * cosAngle,
                            y: center.y + peakRadius * sinAngle
                        )
                        
                        let dotSize: CGFloat = 3.5
                        context.fill(
                            Path(ellipseIn: CGRect(
                                x: peakPt.x - dotSize / 2,
                                y: peakPt.y - dotSize / 2,
                                width: dotSize,
                                height: dotSize
                            )),
                            with: .color(.white.opacity(0.85))
                        )
                    }
                }
                
                // 4. Draw central core reacting to RMS volume
                let coreRadius = minRadius * 0.95 + CGFloat(audioEngine.rmsLevel) * 16
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: center.x - coreRadius / 2,
                        y: center.y - coreRadius / 2,
                        width: coreRadius,
                        height: coreRadius
                    )),
                    with: .radialGradient(
                        Gradient(colors: [.black, .cyan.opacity(0.18), .clear]),
                        center: center,
                        startRadius: 0,
                        endRadius: coreRadius / 2
                    )
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
