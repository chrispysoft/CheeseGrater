//
//  ViewController.swift
//  CheeseGrater - Metal Debug App
//
//  Created by Chris on 12.03.23.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    
    @IBOutlet var metalView: MTKView!
    private var renderer: Renderer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let device = MTLCreateSystemDefaultDevice() {
            metalView.colorPixelFormat = .bgra8Unorm
            metalView.sampleCount = 4
            renderer = Renderer(view: metalView, device: device)
        }
    }
}

