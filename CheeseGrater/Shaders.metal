//
//  Shaders.metal
//  CheeseGrater - Metal Debug App
//
//  Created by Chris on 12.03.23.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
};

struct Uniforms {
    float4x4 matrix;
};

vertex Vertex vertexFunction(constant float2* positions [[buffer(0)]], constant Uniforms& uniforms, uint vertexID [[vertex_id]]) {
    float2 pos = positions[vertexID];
    Vertex out { .position = uniforms.matrix * float4(pos, 0.0, 1.0) };
    return out;
}

fragment float4 fragmentFunction(constant float4& color [[buffer(0)]]) {
    return color;
}
