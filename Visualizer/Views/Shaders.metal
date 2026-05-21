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
    // Soft circular edge
    float alpha = 1.0 - smoothstep(0.0, 0.5, dist);
    // Smooth neon exponential glow
    float glow = exp(-dist * 4.0);
    
    return float4(input.color.rgb * glow * 1.5, alpha * input.color.a);
}
