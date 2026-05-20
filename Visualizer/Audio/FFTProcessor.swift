import Foundation
import AVFoundation
import Accelerate

class FFTProcessor {

    // Fixed FFT window size — always power-of-2, regardless of what AVAudioEngine delivers.
    // 2048 gives ~21 Hz frequency resolution at 44.1 kHz, which is ideal for visualisation.
    private let fftSize = 2048

    private var dftSetup: vDSP_DFT_Setup?
    private var window:     [Float]
    private var windowed:   [Float]
    private var imagInput:  [Float]
    private var realOutput: [Float]
    private var imagOutput: [Float]
    private var logBinsMap: [Range<Int>] = []

    init() {
        window     = Array(repeating: 0.0, count: fftSize)
        windowed   = Array(repeating: 0.0, count: fftSize)
        imagInput  = Array(repeating: 0.0, count: fftSize)
        realOutput = Array(repeating: 0.0, count: fftSize)
        imagOutput = Array(repeating: 0.0, count: fftSize)

        // Create the DFT plan once — fftSize is fixed so this never needs rebuilding.
        // vDSP_DFT_zop_CreateSetup requires 2^a * 3^b * 5^c; 2048 = 2^11 ✓
        dftSetup = vDSP_DFT_zop_CreateSetup(nil, vDSP_Length(fftSize), .FORWARD)
        if dftSetup == nil {
            print("[FFT] FATAL: vDSP_DFT_zop_CreateSetup failed for N=\(fftSize)")
        } else {
            print("[FFT] Ready: N=\(fftSize) (2^11), DFT plan created successfully")
        }

        // Build Hanning window
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))

        // Pre-compute logarithmic bin → 32-band mapping
        buildLogBinsMap()
    }

    deinit {
        if let setup = dftSetup {
            vDSP_DFT_DestroySetup(setup)
        }
    }

    // MARK: - Public

    func process(buffer: AVAudioPCMBuffer) -> [Float] {
        guard let setup = dftSetup else {
            print("[FFT] ERROR: DFT setup is nil — cannot process")
            return Array(repeating: 0.0, count: 32)
        }
        guard let channelData = buffer.floatChannelData?[0] else {
            return Array(repeating: 0.0, count: 32)
        }

        let frameCount = Int(buffer.frameLength)
        let copyCount  = min(frameCount, fftSize)

        // Copy available samples into our fixed-size windowed buffer.
        // Remaining samples stay zero (zero-padding is fine for FFT).
        for i in 0..<fftSize { windowed[i] = 0.0 }
        for i in 0..<copyCount {
            windowed[i] = channelData[i] * window[i]
        }

        // Forward DFT
        vDSP_DFT_Execute(setup, windowed, imagInput, &realOutput, &imagOutput)

        // Compute single-sided linear magnitudes, normalised by N
        let halfSize = fftSize / 2
        var magnitudes = Array(repeating: Float(0.0), count: halfSize)
        for i in 0..<halfSize {
            let r  = realOutput[i]
            let im = imagOutput[i]
            magnitudes[i] = 2.0 * sqrt(r * r + im * im) / Float(fftSize)
        }

        // Map into 32 log-spaced visual bands
        var outputBins = Array(repeating: Float(0.0), count: 32)
        for band in 0..<32 {
            let range = logBinsMap[band]
            var maxVal: Float = 0.0
            for bin in range where bin < halfSize {
                if magnitudes[bin] > maxVal { maxVal = magnitudes[bin] }
            }

            // Perceptual high-frequency boost
            let boost: Float = 1.0 + Float(band) * 0.3
            let boosted = maxVal * boost

            // dB mapping: -90 (noise floor) → -10 (loud)
            let minDB: Float = -90.0
            let maxDB: Float = -10.0
            let db = boosted > 1e-10 ? 20.0 * log10(boosted) : -120.0
            let normalized = (db - minDB) / (maxDB - minDB)

            outputBins[band] = max(0.0, min(1.0, normalized))
        }

        // Diagnostic — fires ~every 2 seconds; remove once bars are confirmed working
        if Int.random(in: 1...100) == 1 {
            let rawMax = magnitudes.max() ?? 0
            let rawDb  = rawMax > 1e-10 ? 20.0 * log10(rawMax) : -120.0
            let binMax = outputBins.max() ?? 0
            print("[FFT] bufLen=\(frameCount) rawMax=\(String(format:"%.5f",rawMax)) (\(String(format:"%.1f",rawDb)) dB) binMax=\(String(format:"%.4f",binMax))")
        }

        return outputBins
    }

    // MARK: - Private

    private func buildLogBinsMap() {
        logBinsMap = []
        let rawBinCount = fftSize / 2
        let minF = 1.0
        let maxF = Double(rawBinCount)

        for i in 0..<32 {
            let pS = Double(i)     / 32.0
            let pE = Double(i + 1) / 32.0
            let s  = Int(exp(log(minF) + pS * log(maxF / minF)))
            let e  = Int(exp(log(minF) + pE * log(maxF / minF)))
            let cs = max(0, min(rawBinCount - 1, s))
            let ce = max(cs + 1, min(rawBinCount, e))
            logBinsMap.append(cs..<ce)
        }
        print("[FFT] Log bin map built: \(logBinsMap.count) bands over \(rawBinCount) raw bins")
    }
}
