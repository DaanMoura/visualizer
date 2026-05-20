import SwiftUI

// MARK: - Main Spectrum Bars View

struct SpectrumBarsVisualizer: View {
    @EnvironmentObject var audioEngine: AudioEngineManager

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<32, id: \.self) { i in
                    SpectrumBar(
                        amplitude: audioEngine.amplitudes[i],
                        peak:      audioEngine.peaks[i],
                        index:     i
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Individual Bar

struct SpectrumBar: View {
    let amplitude: Float
    let peak:      Float
    let index:     Int

    // Hue shifts across the 32 bars: cyan (190°) → magenta (300°)
    private var barColor: Color {
        let t = Double(index) / 31.0
        let hue = 0.527 + t * 0.305   // 0.527 ≈ cyan, 0.832 ≈ magenta
        return Color(hue: hue, saturation: 0.9, brightness: 1.0)
    }

    private var glowColor: Color {
        let t = Double(index) / 31.0
        let hue = 0.527 + t * 0.305
        return Color(hue: hue, saturation: 0.7, brightness: 1.0)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Glow layer (behind bar)
            Rectangle()
                .fill(glowColor.opacity(0.18))
                .frame(height: max(4, CGFloat(amplitude) * 200))
                .blur(radius: 8)

            // Main bar
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [
                            barColor.opacity(0.5),
                            barColor
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(height: max(4, CGFloat(amplitude) * 200))
                .shadow(color: barColor.opacity(0.6), radius: 4, x: 0, y: 0)

            // Peak indicator dot
            if peak > 0.02 {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.white.opacity(0.9))
                    .frame(height: 2)
                    .offset(y: -(CGFloat(peak) * 200) - 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        // Animate every change — SwiftUI handles this natively
        .animation(.linear(duration: 0.04), value: amplitude)
        .animation(.linear(duration: 0.04), value: peak)
    }
}
