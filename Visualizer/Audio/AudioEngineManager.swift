import Foundation
import AVFoundation
import CoreAudio
import AudioToolbox
import Accelerate
import ScreenCaptureKit
import CoreGraphics

class AudioEngineManager: NSObject, ObservableObject {
    enum PermissionState {
        case undetermined
        case granted
        case denied
    }

    enum CaptureSource: String, CaseIterable, Identifiable {
        case microphone = "Microphone"
        case systemAudio = "System Audio"
        
        var id: String { rawValue }
    }

    struct InputDevice: Identifiable, Equatable {
        let id: AudioObjectID
        let name: String

        var isDefaultPlaceholder: Bool {
            id == AudioObjectID(kAudioObjectUnknown)
        }
    }
    
    @Published var permissionState: PermissionState = .undetermined
    @Published var screenCapturePermissionState: PermissionState = .undetermined
    @Published var captureSource: CaptureSource = .microphone
    @Published var isAudioActive = false
    
    @Published var activeDeviceName: String = "Default Input"
    @Published var rmsLevel: Float = 0.0
    @Published private(set) var availableInputDevices: [InputDevice] = []
    @Published private(set) var selectedInputDevice: InputDevice?
    
    // We publish 32 frequency bands for the Spectrum Bars visualizer
    @Published var amplitudes: [Float] = Array(repeating: 0.0, count: 32)
    @Published var peaks: [Float] = Array(repeating: 0.0, count: 32)
    
    private let audioEngine = AVAudioEngine()
    private var isEngineRunning = false
    private let fftProcessor = FFTProcessor()
    private let defaultInputDevice = InputDevice(
        id: AudioObjectID(kAudioObjectUnknown),
        name: "System Default Input"
    )
    private var hardwareDevicesListener: AudioObjectPropertyListenerBlock?
    
    // ScreenCaptureKit properties
    private var scStream: SCStream?
    private var isSCStreamRunning = false
    
    // Smooth decay values
    private var peakHoldFrames: [Int] = Array(repeating: 0, count: 32)
    
    private let fftBinCount = 32
    
    override init() {
        super.init()
        refreshInputDevices()
        checkPermission()
        setupNotifications()
    }
    
    deinit {
        stopAudioStream()
        removeHardwareDeviceListener()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            permissionState = .granted
        case .denied, .restricted:
            permissionState = .denied
        case .notDetermined:
            permissionState = .undetermined
        @unknown default:
            permissionState = .undetermined
        }
        
        checkScreenCapturePermission()
        
        if hasPermission(for: captureSource) {
            startAudioStream()
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted {
                    self.permissionState = .granted
                    if self.captureSource == .microphone {
                        self.startAudioStream()
                    }
                } else {
                    self.permissionState = .denied
                }
            }
        }
    }
    
    func checkScreenCapturePermission() {
        if CGPreflightScreenCaptureAccess() {
            screenCapturePermissionState = .granted
        } else {
            screenCapturePermissionState = .denied
        }
    }
    
    func requestScreenCapturePermission() {
        _ = CGRequestScreenCaptureAccess()
        
        // Dynamic recheck after triggering the request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.checkScreenCapturePermission()
            if self.screenCapturePermissionState == .granted && self.captureSource == .systemAudio {
                self.startAudioStream()
            }
        }
    }
    
    func hasPermission(for source: CaptureSource) -> Bool {
        switch source {
        case .microphone:
            return permissionState == .granted
        case .systemAudio:
            return screenCapturePermissionState == .granted
        }
    }
    
    func switchCaptureSource(_ source: CaptureSource) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.captureSource != source else { return }
            
            print("Switching capture source to \(source.rawValue)...")
            self.stopAudioStream()
            self.captureSource = source
            
            self.checkPermission()
            
            if self.hasPermission(for: source) {
                self.startAudioStream()
            }
        }
    }

    func selectInputDevice(_ device: InputDevice) {
        refreshInputDevices()

        let nextDevice = availableInputDevices.first { $0.id == device.id } ?? defaultInputDevice
        selectedInputDevice = nextDevice
        
        // Auto switch back to microphone if they select a device
        if captureSource != .microphone {
            captureSource = .microphone
            checkPermission()
        } else {
            updateActiveDevice()
        }

        guard permissionState == .granted else { return }

        let shouldRestart = isEngineRunning || isAudioActive
        stopAudioStream()

        if shouldRestart || !isAudioActive {
            startAudioStream()
        }
    }
    
    func startAudioStream() {
        print("Starting stream for source: \(captureSource.rawValue)...")
        switch captureSource {
        case .microphone:
            startMicrophoneStream()
        case .systemAudio:
            startSystemAudioStream()
        }
    }
    
    func stopAudioStream() {
        print("Stopping all audio streams...")
        stopMicrophoneStream()
        stopSystemAudioStream()
    }
    
    private func startMicrophoneStream() {
        guard permissionState == .granted else { return }
        guard !isEngineRunning else { return }
        
        print("Initializing AVAudioEngine capture stream...")
        refreshInputDevices()
        
        let inputNode = audioEngine.inputNode
        var captureDevice = selectedInputDevice ?? defaultInputDevice

        if !configureInputDevice(captureDevice) {
            print("Could not use selected input '\(captureDevice.name)'. Falling back to default input.")
            captureDevice = defaultInputDevice
            selectedInputDevice = defaultInputDevice
            _ = configureInputDevice(defaultInputDevice)
        }

        var inputFormat = inputNode.inputFormat(forBus: 0)
        
        // Handle potential sample rate error state (e.g. rate is 0 on startup)
        if inputFormat.sampleRate <= 0, !captureDevice.isDefaultPlaceholder {
            print("Selected input '\(captureDevice.name)' has an invalid sample rate. Falling back to default input.")
            captureDevice = defaultInputDevice
            selectedInputDevice = defaultInputDevice
            _ = configureInputDevice(defaultInputDevice)
            inputFormat = inputNode.inputFormat(forBus: 0)
        }

        guard inputFormat.sampleRate > 0 else {
            print("Error: Input device sample rate is invalid (0). Retrying later.")
            isEngineRunning = false
            isAudioActive = false
            return
        }
        updateActiveDevice()
        
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
            print("AVAudioEngine started successfully. Tapping \(activeDeviceName).")
        } catch {
            print("Failed to start AVAudioEngine: \(error.localizedDescription)")
            isEngineRunning = false
            isAudioActive = false
        }
    }
    
    private func stopMicrophoneStream() {
        guard isEngineRunning else { return }
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        isEngineRunning = false
        isAudioActive = false
        print("AVAudioEngine stopped.")
    }
    
    private func startSystemAudioStream() {
        // Will be implemented in Phase 2
        print("startSystemAudioStream called")
    }
    
    private func stopSystemAudioStream() {
        // Will be implemented in Phase 2
        print("stopSystemAudioStream called")
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
        addHardwareDeviceListener()
    }
    
    @objc private func handleRouteChange() {
        print("Audio route configuration changed. Resetting tap...")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let wasActive = self.isAudioActive
            self.refreshInputDevices()
            self.stopAudioStream()
            if wasActive {
                self.startAudioStream()
            }
        }
    }
    

    func refreshInputDevices() {
        let devices = enumerateInputDevices()
        let nextDevices = [defaultInputDevice] + devices
        let currentSelection = selectedInputDevice ?? defaultInputDevice
        let nextSelection = nextDevices.first { $0.id == currentSelection.id } ?? defaultInputDevice

        if Thread.isMainThread {
            availableInputDevices = nextDevices
            selectedInputDevice = nextSelection
            updateActiveDevice()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.availableInputDevices = nextDevices
                self?.selectedInputDevice = nextSelection
                self?.updateActiveDevice()
            }
        }
    }

    private func configureInputDevice(_ device: InputDevice) -> Bool {
        guard let audioUnit = audioEngine.inputNode.audioUnit else {
            return device.isDefaultPlaceholder
        }

        guard var deviceID = device.isDefaultPlaceholder ? defaultInputDeviceID() : Optional(device.id) else {
            return false
        }

        let status = AudioUnitSetProperty(
            audioUnit,
            kAudioOutputUnitProperty_CurrentDevice,
            kAudioUnitScope_Global,
            0,
            &deviceID,
            UInt32(MemoryLayout<AudioObjectID>.size)
        )

        return status == noErr
    }

    private func defaultInputDeviceID() -> AudioObjectID? {
        var deviceID = AudioObjectID(kAudioObjectUnknown)
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

        guard status == noErr, deviceID != AudioObjectID(kAudioObjectUnknown) else {
            return nil
        }

        return deviceID
    }

    private func enumerateInputDevices() -> [InputDevice] {
        var propertySize: UInt32 = 0
        var devicesAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let sizeStatus = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &devicesAddress,
            0,
            nil,
            &propertySize
        )

        guard sizeStatus == noErr, propertySize > 0 else {
            return []
        }

        let deviceCount = Int(propertySize) / MemoryLayout<AudioObjectID>.size
        var deviceIDs = Array(repeating: AudioObjectID(0), count: deviceCount)
        let deviceStatus = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &devicesAddress,
            0,
            nil,
            &propertySize,
            &deviceIDs
        )

        guard deviceStatus == noErr else {
            return []
        }

        return deviceIDs
            .filter { hasInputStreams(deviceID: $0) }
            .compactMap { deviceID in
                guard let name = inputDeviceName(for: deviceID) else { return nil }
                return InputDevice(id: deviceID, name: name)
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func hasInputStreams(deviceID: AudioObjectID) -> Bool {
        var streamConfigAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        var propertySize: UInt32 = 0

        let sizeStatus = AudioObjectGetPropertyDataSize(
            deviceID,
            &streamConfigAddress,
            0,
            nil,
            &propertySize
        )

        guard sizeStatus == noErr, propertySize > 0 else {
            return false
        }

        let bufferListPointer = UnsafeMutableRawPointer.allocate(
            byteCount: Int(propertySize),
            alignment: MemoryLayout<AudioBufferList>.alignment
        )
        defer {
            bufferListPointer.deallocate()
        }

        let dataStatus = AudioObjectGetPropertyData(
            deviceID,
            &streamConfigAddress,
            0,
            nil,
            &propertySize,
            bufferListPointer
        )

        guard dataStatus == noErr else {
            return false
        }

        let bufferList = UnsafeMutableAudioBufferListPointer(
            bufferListPointer.assumingMemoryBound(to: AudioBufferList.self)
        )
        return bufferList.contains { $0.mNumberChannels > 0 }
    }

    private func inputDeviceName(for deviceID: AudioObjectID) -> String? {
        var unmanagedName: Unmanaged<CFString>?
        var propertySize = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        var nameAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceNameCFString,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(
            deviceID,
            &nameAddress,
            0,
            nil,
            &propertySize,
            &unmanagedName
        )

        guard status == noErr, let unmanagedName else {
            return nil
        }

        return unmanagedName.takeUnretainedValue() as String
    }

    private func addHardwareDeviceListener() {
        guard hardwareDevicesListener == nil else { return }

        var devicesAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let listener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
            self?.refreshInputDevices()
        }

        AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &devicesAddress,
            DispatchQueue.main,
            listener
        )

        hardwareDevicesListener = listener
    }

    private func removeHardwareDeviceListener() {
        guard let hardwareDevicesListener else { return }

        var devicesAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectRemovePropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &devicesAddress,
            DispatchQueue.main,
            hardwareDevicesListener
        )

        self.hardwareDevicesListener = nil
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
        
        if let selectedInputDevice, !selectedInputDevice.isDefaultPlaceholder {
            return selectedInputDevice.name
        }

        if let name = inputDeviceName(for: deviceID) {
            return name
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
