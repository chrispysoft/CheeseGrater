//
//  TriangleMesh.swift
//  CheeseGrater - Metal Debug App
//
//  Created by Chris on 12.03.23.
//

import MetalKit

class TriangleMesh: Mesh {
    init(device: MTLDevice, color: MTLClearColor) {
        let positions = [
            SIMD2<Float>(-1, -1),
            SIMD2<Float>( 0,  1),
            SIMD2<Float>( 1, -1),
            SIMD2<Float>(-1, -1)
        ]
        super.init(device: device, positions: positions, color: color)
    }
}


class Mesh {
    private var positions: [SIMD2<Float>]
    private let vertexBuffer: MTLBuffer
    private let drawMode: MTLPrimitiveType
    
    public var color = vector_float4(0,0,0,0)
    public var matrix = matrix_float4x4(1)
    
    
    init(device: MTLDevice, positions: [SIMD2<Float>], color: MTLClearColor) {
        self.positions = positions
        self.vertexBuffer = device.makeBuffer(bytes: positions, length: MemoryLayout<SIMD2<Float>>.stride * positions.count, options: .storageModeShared)!
        self.drawMode = .triangle
        self.color = color.vector_float4
    }
    
    
    public func render(with encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBytes(&matrix, length: MemoryLayout.stride(ofValue: matrix), index: 1)
        encoder.setFragmentBytes(&color, length: MemoryLayout.stride(ofValue: color), index: 0)
        encoder.drawPrimitives(type: drawMode, vertexStart: 0, vertexCount: positions.count)
    }
}


fileprivate extension MTLClearColor {
    var vector_float4: vector_float4 {
        return simd.vector_float4(Float(self.red), Float(self.green), Float(self.blue), Float(self.alpha))
    }
}


public extension matrix_float4x4 {
    
    mutating func translate(x: Float? = nil, y: Float? = nil, z: Float? = nil) {
        if let x = x { columns.3.x = x }
        if let y = y { columns.3.y = y }
        if let z = z { columns.3.z = z }
    }
    
    mutating func scale(x: Float? = nil, y: Float? = nil, z: Float? = nil) {
        if let x = x { columns.0.x = x }
        if let y = y { columns.1.y = y }
        if let z = z { columns.2.z = z }
    }
    
    mutating func mirrorY() {
        columns.1.y *= -1
    }
}
