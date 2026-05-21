import SwiftUI
import MetalKit
import simd

struct MetalParticle: Decodable {
    var position: simd_float2
    var velocity: simd_float2
    var color: simd_float4
    var size: Float
}

struct ParticleState {
    var baseRadius: Float
    var angle: Float
    var orbitSpeed: Float
    var radialSpeed: Float
    var baseSize: Float
    var bandIndex: Int
    var hue: Float
}

struct MetalParticleVisualizer: View {
    @EnvironmentObject var audioEngine: AudioEngineManager

    var body: some View {
        MetalParticleViewRepresentable()
            .environmentObject(audioEngine)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.1)) // Sleek transparent background
    }
}

struct MetalParticleViewRepresentable: NSViewRepresentable {
    @EnvironmentObject var audioEngine: AudioEngineManager

    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.isPaused = false
        mtkView.enableSetNeedsDisplay = false
        mtkView.layer?.isOpaque = false // Transparent layer capability
        
        context.coordinator.setupMetal(view: mtkView)
        mtkView.delegate = context.coordinator
        
        return mtkView
    }

    func updateNSView(_ nsView: MTKView, context: Context) {
        // Safe context updates if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(audioEngine: audioEngine)
    }

    class Coordinator: NSObject, MTKViewDelegate {
        var audioEngine: AudioEngineManager
        var device: MTLDevice?
        var commandQueue: MTLCommandQueue?
        var pipelineState: MTLRenderPipelineState?
        var particleBuffer: MTLBuffer?
        
        let maxParticles = 6000
        var particleStates: [ParticleState] = []
        var metalParticles: [MetalParticle] = []

        init(audioEngine: AudioEngineManager) {
            self.audioEngine = audioEngine
            super.init()
            setupParticles()
        }

        func setupParticles() {
            particleStates.removeAll()
            metalParticles.removeAll()
            
            for i in 0..<maxParticles {
                let state = ParticleState(
                    baseRadius: Float.random(in: 0.05...1.1),
                    angle: Float.random(in: 0...(2 * .pi)),
                    orbitSpeed: Float.random(in: 0.003...0.015),
                    radialSpeed: Float.random(in: -0.001...0.001),
                    baseSize: Float.random(in: 4.0...9.0),
                    bandIndex: i % 32,
                    hue: Float(i % 32) / 32.0
                )
                particleStates.append(state)
                
                let p = MetalParticle(
                    position: simd_float2(0, 0),
                    velocity: simd_float2(0, 0),
                    color: simd_float4(1, 1, 1, 1),
                    size: state.baseSize
                )
                metalParticles.append(p)
            }
        }

        func setupMetal(view: MTKView) {
            guard let device = view.device else { return }
            self.device = device
            self.commandQueue = device.makeCommandQueue()
            
            // Build the Shader Library
            // First try default library compiled in build, then compile from source for maximum runtime robustness
            var library: MTLLibrary? = device.makeDefaultLibrary()
            
            if library == nil {
                // Runtime compilation fallback
                let shaderSource = """
                #include <metal_stdlib>
                using namespace metal;

                struct MetalParticle {
                    float2 position;
                    float2 velocity;
                    float4 color;
                    float size;
                };

                struct VertexOut {
                    float4 position [[position]];
                    float4 color;
                    float point_size [[point_size]];
                };

                vertex VertexOut particle_vertex(device const MetalParticle* particles [[buffer(0)]],
                                                 uint vid [[vertex_id]]) {
                    VertexOut out;
                    device const MetalParticle& p = particles[vid];
                    out.position = float4(p.position, 0.0, 1.0);
                    out.color = p.color;
                    out.point_size = p.size;
                    return out;
                }

                fragment float4 particle_fragment(VertexOut input [[stage_in]],
                                                   float2 point_coord [[point_coord]]) {
                    float dist = length(point_coord - float2(0.5));
                    float alpha = 1.0 - smoothstep(0.0, 0.5, dist);
                    float glow = exp(-dist * 4.0);
                    return float4(input.color.rgb * glow * 1.5, alpha * input.color.a);
                }
                """
                library = try? device.makeLibrary(source: shaderSource, options: nil)
            }
            
            guard let library = library,
                  let vertexFunction = library.makeFunction(name: "particle_vertex"),
                  let fragmentFunction = library.makeFunction(name: "particle_fragment") else {
                return
            }
            
            // Define Render Pipeline
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
            
            // Setup glowing additive blending
            let colorAttachment = pipelineDescriptor.colorAttachments[0]
            colorAttachment?.isBlendingEnabled = true
            colorAttachment?.rgbBlendOperation = .add
            colorAttachment?.alphaBlendOperation = .add
            colorAttachment?.sourceRGBBlendFactor = .sourceAlpha
            colorAttachment?.sourceAlphaBlendFactor = .one
            colorAttachment?.destinationRGBBlendFactor = .one
            colorAttachment?.destinationAlphaBlendFactor = .one
            
            do {
                self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("Failed to initialize Metal pipeline state: \(error)")
            }
            
            // Preallocate shared memory buffer for particles to eliminate render allocations
            let bufferSize = MemoryLayout<MetalParticle>.stride * maxParticles
            self.particleBuffer = device.makeBuffer(length: bufferSize, options: .storageModeShared)
        }

        func updatePhysics(width: Float, height: Float) {
            let aspect = width / height
            let rms = audioEngine.rmsLevel
            let amplitudes = audioEngine.amplitudes
            
            for i in 0..<maxParticles {
                var state = particleStates[i]
                let amp = amplitudes[state.bandIndex]
                
                // Orbit increases with overall energy (RMS)
                state.angle += state.orbitSpeed * (1.0 + Float(rms) * 3.5)
                
                // Spiral expansion reacting directly to band energy and peak beats
                let radialExpansion = amp * 0.35 + Float(rms) * 0.15
                let radius = state.baseRadius + radialExpansion
                
                // Aspect ratio mapping to guarantee perfect circular orbital patterns
                let x = radius * cos(state.angle) / aspect
                let y = radius * sin(state.angle)
                
                metalParticles[i].position = simd_float2(x, y)
                
                // Dynamic hue shift matching music beats
                let currentHue = fmod(state.hue + Float(rms) * 0.15, 1.0)
                metalParticles[i].color = hsbaToRgba(h: currentHue, s: 0.92, b: 1.0, a: 0.42 + amp * 0.58)
                
                // Particle size breathing with amplitude
                metalParticles[i].size = state.baseSize * (1.0 + amp * 2.2)
                
                particleStates[i] = state
            }
        }

        func draw(in view: MTKView) {
            guard let device = device,
                  let commandQueue = commandQueue,
                  let pipelineState = pipelineState,
                  let particleBuffer = particleBuffer,
                  let renderPassDescriptor = view.currentRenderPassDescriptor,
                  let drawable = view.currentDrawable else {
                return
            }
            
            let width = Float(view.drawableSize.width)
            let height = Float(view.drawableSize.height)
            guard width > 0 && height > 0 else { return }
            
            // 1. Run physics simulation on the rendering thread
            updatePhysics(width: width, height: height)
            
            // 2. Load into GPU Buffer
            let contents = particleBuffer.contents().bindMemory(to: MetalParticle.self, capacity: maxParticles)
            for i in 0..<maxParticles {
                contents[i] = metalParticles[i]
            }
            
            // 3. Render Pass
            guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
            
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].storeAction = .store
            
            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                return
            }
            
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: maxParticles)
            
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Handled dynamically on every frame using drawableSize width and height
        }

        // Beautiful HSB -> RGBA conversion helper
        private func hsbaToRgba(h: Float, s: Float, b: Float, a: Float) -> simd_float4 {
            var r: Float = 0
            var g: Float = 0
            var bl: Float = 0
            let i = Int(h * 6)
            let f = h * 6 - Float(i)
            let p = b * (1 - s)
            let q = b * (1 - f * s)
            let t = b * (1 - (1 - f) * s)
            switch i % 6 {
            case 0: r = b; g = t; bl = p
            case 1: r = q; g = b; bl = p
            case 2: r = p; g = b; bl = t
            case 3: r = p; g = q; bl = b
            case 4: r = t; g = p; bl = b
            case 5: r = b; g = p; bl = q
            default: break
            }
            return simd_float4(r, g, bl, a)
        }
    }
}
