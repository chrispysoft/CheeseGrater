//
//  Renderer.swift
//  CheeseGrater - Metal Debug App
//
//  Created by Chris on 12.03.23.
//

import MetalKit

class Renderer: NSObject {
    
    private static let vertexFunctionName = "vertexFunction"
    private static let fragmentFunctionName = "fragmentFunction"
    private static var vertexDescriptor: MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        descriptor.attributes[0].format = .float2
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].offset = 0
        descriptor.attributes[1].format = .float3
        descriptor.attributes[1].bufferIndex = 1
        descriptor.attributes[1].offset = 0
        descriptor.layouts[0].stride = MemoryLayout<SIMD2<Float>>.stride
        descriptor.layouts[1].stride = MemoryLayout<SIMD3<Float>>.stride
        return descriptor
    }
    
    private unowned let view: MTKView
    private unowned let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let renderPipelineState: MTLRenderPipelineState
    private var meshes: [Mesh] = []
    
    public var clearColor = MTLClearColor() { didSet { view.clearColor = clearColor }}
    
    /*
     crash if something goes wrong
     */
    init(view: MTKView, device: MTLDevice) {
        self.view = view
        self.device = device
        
        commandQueue = device.makeCommandQueue()!
        
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: Renderer.vertexFunctionName)!
        let fragmentFunction = library.makeFunction(name: Renderer.fragmentFunctionName)!
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.vertexDescriptor = Renderer.vertexDescriptor
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        descriptor.rasterSampleCount = view.sampleCount
        
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
        
        let triangleMesh = TriangleMesh(device: device, color: NSColor.blue.mtlClearColor)
        triangleMesh.matrix.scale(x: 0.9, y: 0.9)
        meshes.append(triangleMesh)
        
        super.init()
        
        view.device = device
        view.delegate = self
    }
}



extension Renderer: MTKViewDelegate {
    /*
     handle errors if we got so far
     */
    func draw(in view: MTKView) {
        if let drawable = view.currentDrawable {
            guard let descriptor = view.currentRenderPassDescriptor else { NSLog("currentRenderPassDescriptor is nil"); return }
            guard let cmdBuffer = commandQueue.makeCommandBuffer() else { NSLog("makeCommandBuffer returned nil"); return }
            guard let cmdEncoder = cmdBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { NSLog("makeRenderCommandEncoder returned nil"); return }
            cmdEncoder.setRenderPipelineState(renderPipelineState)
            meshes.forEach {
                $0.render(with: cmdEncoder)
            }
            cmdEncoder.endEncoding()
            cmdBuffer.present(drawable)
            cmdBuffer.commit()
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
}


extension NSColor {
    var mtlClearColor: MTLClearColor {
        return MTLClearColor(red: self.redComponent, green: self.greenComponent, blue: self.blueComponent, alpha: self.alphaComponent)
    }
}

