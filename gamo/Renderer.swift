//
//  Renderer.swift
//  gamo
//
//  Created by Khrob Edmonds on 11/1/19.
//  Copyright © 2019 TangoSoup. All rights reserved.
//

import MetalKit

struct Vector4
{
    let x:Float
    let y:Float
    let z:Float
    let w:Float
}

class Metal_View : MTKView
{
    var commandQueue: MTLCommandQueue!
    var compute_pipeline_state: MTLComputePipelineState!
    
    required init(coder: NSCoder)
    {
        super.init(coder: coder)
        framebufferOnly = false
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device!.makeCommandQueue()
        let library = device!.makeDefaultLibrary()!
        let compute = library.makeFunction(name: "compute")!
        do { try compute_pipeline_state = device!.makeComputePipelineState(function: compute) }
        catch let error { print(error) }
        
        startup()
        
        uniforms_buffer = make_uniforms_buffer(device!, uniforms: &uniforms)
        capsules_buffer = make_capsules_buffer(device!, geometry: &test_capsules)
    }
    
    override func draw()
    {
        super.draw()
        
        if let drawable = currentDrawable,
            let commandBuffer = commandQueue!.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        {
            let thread_group_count = MTLSizeMake(8, 8, 1)
            let thread_groups = MTLSizeMake(drawable.texture.width / thread_group_count.width, drawable.texture.height / thread_group_count.height, 1)
            
            update()
            
            commandEncoder.setComputePipelineState(compute_pipeline_state)
            commandEncoder.setTexture(drawable.texture, index: 0)
            commandEncoder.setBuffer(uniforms_buffer, offset: 0, index: 0)
            commandEncoder.setBuffer(capsules_buffer, offset: 0, index: 1)
            commandEncoder.dispatchThreadgroups(thread_groups, threadsPerThreadgroup: thread_group_count)
            commandEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
        else {
            print ("Couldn't create a valid drawable, buffer or encoder")
        }
    }
}

