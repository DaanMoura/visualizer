import Foundation
import AVFoundation
import CoreAudio
import Accelerate

class AudioEngineManager: ObservableObject {
    enum PermissionState {
        case undetermined
        case granted
        case denied
    }
    
    @Published var permissionState: PermissionState = .undetermined
    @Published var isAudioActive = false
    
    @Published var activeDeviceName: String = "Default Input"
    @Published var rmsLevel: Float = 0.0
    
    // We publish 32 frequency bands for the Spectrum Bars visualizer
    @Published var amplitudes: [Float] = Array(repeating: 0.0, count: 32)
    @Published var peaks: [Float] = Array(repeating: 0.0, count: 32)
    
    private let audioEngine = AVAudioEngine()
    private var isEngineRunning = false
    private let fftProcessor = FFTProcessor()
    
    // Smooth decay values
    private var peakHoldFrames: [Int] = Array(repeating: 0, count: 32)
    
    private let fftBinCount = 32
    
    init() {
        checkPermission()
        setupNotifications()
    }
    
    deinit {
        stopAudioStream()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            permissionState = .granted
            startAudioStream()
        case .denied, .restricted:
            permissionState = .denied
        case .notDetermined:
            permissionState = .undetermined
        @unknown default:
            permissionState = .undetermined
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.permissionState = .granted
                    self?.startAudioStream()
                } else {
                    self?.permissionState = .denied
                }
            }
        }
    }
    
    func startAudioStream() {
        guard permissionState == .granted else { return }
        guard !isEngineRunning else { return }
        
        print("Initializing AVAudioEngine capture stream...")
        updateActiveDevice()
        
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        // Handle potential sample rate error state (e.g. rate is 0 on startup)
        guard inputFormat.sampleRate > 0 else {
            print("Error: Input device sample rate is invalid (0). Retrying later...")
            return
        }
        
        // Remove tap if already installed to prevent crashes
        inputNode.removeTap(onBus: 0)
        
        // Install audio tap
        // We use 1024 frames for a balance of low latency and good frequency resolution
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, time in
            self?.processAudioBuffer(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isEngineRunning = true
            isAudioActive = true
            print("AVAudioEngine started successfully. Tapping default input.")
        } catch {
            print("Failed to start AVAudioEngine: \(error.localizedDescription)")
            isEngineRunning = false
            isAudioActive = false
        }
    }
    
    func stopAudioStream() {
        guard isEngineRunning else { return }
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        isEngineRunning = false
        isAudioActive = false
        print("AVAudioEngine stopped.")
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Calculate real-time RMS input volume
        var rms: Float = 0.0
        if let channelData = buffer.floatChannelData?[0] {
            vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(buffer.frameLength))
        }
        
        // FFT computation is performed in FFTProcessor
        let bins = fftProcessor.process(buffer: buffer)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.rmsLevel = rms
            
            let decay: Float = 0.82 // Smooth interpolation decay factor for falling bars
            let gravity: Float = 0.015 // Gravity pull per frame for peaks
            let peakHoldLimit = 15 // Frame count before a peak starts to drop
            
            var newAmplitudes = self.amplitudes
            var newPeaks = self.peaks
            
            for i in 0..<self.fftBinCount {
                let target = i < bins.count ? bins[i] : 0.0
                let current = newAmplitudes[i]
                
                let nextValue = current * decay + target * (1.0 - decay)
                newAmplitudes[i] = max(0.0, min(1.0, nextValue))
                
                let currentPeak = newPeaks[i]
                if newAmplitudes[i] >= currentPeak {
                    newPeaks[i] = newAmplitudes[i]
                    self.peakHoldFrames[i] = peakHoldLimit
                } else {
                    if self.peakHoldFrames[i] > 0 {
                        self.peakHoldFrames[i] -= 1
                    } else {
                        let nextPeak = currentPeak - gravity
                        newPeaks[i] = max(newAmplitudes[i], max(0.0, nextPeak))
                    }
                }
            }
            
            self.amplitudes = newAmplitudes
            self.peaks = newPeaks
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: Notification.Name.AVAudioEngineConfigurationChange,
            object: nil
        )
    }
    
    @objc private func handleRouteChange() {
        print("Audio route configuration changed. Resetting tap...")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let wasActive = self.isAudioActive
            self.stopAudioStream()
            if wasActive {
                self.startAudioStream()
            }
        }
    }
    

    
    private func getActiveInputDeviceName() -> String {
        var deviceID = AudioObjectID(0)
        var size = UInt32(MemoryLayout<AudioObjectID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &deviceID
        )
        
        guard status == noErr else {
            return "Default Input"
        }
        
        var nameSize = UInt32(0)
        var nameAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        let statusSize = AudioObjectGetPropertyDataSize(
            deviceID,
            &nameAddress,
            0,
            nil,
            &nameSize
        )
        
        guard statusSize == noErr else {
            return "Default Input"
        }
        
        var deviceName: CFString? = nil
        let statusName = AudioObjectGetPropertyData(
            deviceID,
            &nameAddress,
            0,
            nil,
            &nameSize,
            &deviceName
        )
        
        if statusName == noErr, let name = deviceName {
            return name as String
        }
        
        return "Default Input"
    }
    
    func updateActiveDevice() {
        let name = getActiveInputDeviceName()
        DispatchQueue.main.async { [weak self] in
            self?.activeDeviceName = name
        }
    }
}
