import Foundation
import AVFoundation
import Accelerate

class FFTProcessor {
    private var dftSetup: vDSP_DFT_Setup?
    private var fftLength: Int = 0
    private var logBinsMap: [Range<Int>] = []
    
    deinit {
        if let setup = dftSetup {
            vDSP_DFT_DestroySetup(setup)
        }
    }
    
    func process(buffer: AVAudioPCMBuffer) -> [Float] {
        guard let channelData = buffer.floatChannelData?[0] else {
            return Array(repeating: 0.0, count: 32)
        }
        
        let frameCount = Int(buffer.frameLength)
        
        // Re-initialize setup if frame length changes
        if fftLength != frameCount {
            setupFFT(length: frameCount)
        }
        
        guard let setup = dftSetup else {
            return Array(repeating: 0.0, count: 32)
        }
        
        // Prepare complex arrays
        let realInput = Array(UnsafeBufferPointer(start: channelData, count: frameCount))
        var imagInput = Array(repeating: Float(0.0), count: frameCount)
        
        var realOutput = Array(repeating: Float(0.0), count: frameCount)
        var imagOutput = Array(repeating: Float(0.0), count: frameCount)
        
        // Run forward DFT (Discrete Fourier Transform) using Accelerate
        vDSP_DFT_Execute(setup, realInput, imagInput, &realOutput, &imagOutput)
        
        // Compute magnitudes: |X(k)| = sqrt(real^2 + imag^2)
        let halfLength = frameCount / 2
        var magnitudes = Array(repeating: Float(0.0), count: halfLength)
        
        for i in 0..<halfLength {
            let r = realOutput[i]
            let im = imagOutput[i]
            // Magnitude scaled by total frame size to normalize amplitudes
            let mag = sqrt(r * r + im * im) / Float(frameCount)
            magnitudes[i] = mag
        }
        
        // Logarithmic grouping into 32 distinct visual frequency bands
        var outputBins = Array(repeating: Float(0.0), count: 32)
        for band in 0..<32 {
            let range = logBinsMap[band]
            var maxVal: Float = 0.0
            for bin in range {
                if magnitudes[bin] > maxVal {
                    maxVal = magnitudes[bin]
                }
            }
            
            // Boost factor for high frequency bands which naturally have lower physical sound energy
            let highFreqBoost = 1.0 + Float(band) * 0.18
            let boostedVal = maxVal * highFreqBoost
            
            // Logarithmic amplitude scaling using standard engineering decibel mapping (-65 dB to -15 dB)
            let minDB: Float = -65.0
            let maxDB: Float = -15.0
            let db = 20.0 * log10(max(boostedVal, 1e-5))
            let normalized = (db - minDB) / (maxDB - minDB)
            
            outputBins[band] = max(0.0, min(1.0, normalized))
        }
        
        return outputBins
    }
    
    private func setupFFT(length: Int) {
        if let setup = dftSetup {
            vDSP_DFT_DestroySetup(setup)
        }
        
        fftLength = length
        // Create 1D Forward Discrete Fourier Transform setup from Accelerate
        dftSetup = vDSP_DFT_zop_CreateSetup(nil, vDSP_Length(length), .FORWARD)
        
        // Pre-calculate logarithmic bin mappings
        logBinsMap = []
        let rawBinCount = length / 2
        
        // Group the raw FFT index ranges logarithmically to match human hearing
        let minFreq = 1.0
        let maxFreq = Double(rawBinCount)
        
        for i in 0..<32 {
            let progressStart = Double(i) / 32.0
            let progressEnd = Double(i + 1) / 32.0
            
            let start = Int(exp(log(minFreq) + progressStart * log(maxFreq / minFreq)))
            let end = Int(exp(log(minFreq) + progressEnd * log(maxFreq / minFreq)))
            
            let clampedStart = max(0, min(rawBinCount - 1, start))
            let clampedEnd = max(clampedStart + 1, min(rawBinCount, end))
            
            logBinsMap.append(clampedStart..<clampedEnd)
        }
    }
}
