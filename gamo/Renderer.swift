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
    var x : Float = 0.0
    var y : Float = 0.0
    var z : Float = 0.0
    var w : Float = 0.0
}

class Metal_View : MTKView
{
    var commandQueue: MTLCommandQueue!
    var compute_pipeline_state: MTLComputePipelineState!
    
    required init(coder: NSCoder)
    {
        super.init(coder: coder)
        
        // Configure the Metal stuff
        
        framebufferOnly = false
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device!.makeCommandQueue()
        let library = device!.makeDefaultLibrary()!
        let compute = library.makeFunction(name: "compute")!
        do { try compute_pipeline_state = device!.makeComputePipelineState(function: compute) }
        catch let error { print(error) }
        
        // Set up the game stuff
        
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
    
    // MARK: Keyboard Handling
    
    let ESC_Key         : UInt16 = 0x35
    let Tilde_Key       : UInt16 = 0x32
    let Left_Arrow_Key  : UInt16 = 0x7B
    let Right_Arrow_Key : UInt16 = 0x7C
    let Down_Arrow_Key  : UInt16 = 0x7D
    let Up_Arrow_Key    : UInt16 = 0x7E
    let W_Key           : UInt16 = 0x0D
    let A_Key           : UInt16 = 0x00
    let S_Key           : UInt16 = 0x01
    let D_Key           : UInt16 = 0x02
    let F_Key           : UInt16 = 0x03
    let Q_Key           : UInt16 = 0x0C
    let R_Key           : UInt16 = 0x0F
    
    override func keyDown(with event: NSEvent)
    {
        print ("pressed key: \(event.keyCode)")
        
        switch event.keyCode {
        case Left_Arrow_Key, A_Key  : input.left_pressed  = true
        case Right_Arrow_Key, D_Key : input.right_pressed = true
        case Down_Arrow_Key, S_Key  : input.down_pressed  = true
        case Up_Arrow_Key, W_Key    : input.up_pressed    = true
        case ESC_Key: toggle_grab_mouse()
        default: break
        }
    }
    
    override func keyUp(with event: NSEvent)
    {
        switch event.keyCode {
        case Left_Arrow_Key, A_Key  : input.left_pressed  = false
        case Right_Arrow_Key, D_Key : input.right_pressed = false
        case Down_Arrow_Key, S_Key  : input.down_pressed  = false
        case Up_Arrow_Key, W_Key    : input.up_pressed    = false
        default: break
        }
    }
    
    // MARK: Mouse Tracking
    
    var tracking_area : NSTrackingArea?
    
    override func updateTrackingAreas()
    {
        super.updateTrackingAreas()
        if tracking_area != nil { removeTrackingArea(tracking_area!) }
        let tracking_options : NSTrackingArea.Options = [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow]
        tracking_area = NSTrackingArea(rect: bounds, options: tracking_options, owner: self, userInfo: nil)
        addTrackingArea(tracking_area!)
    }
    
    override func mouseMoved(with event: NSEvent)
    {
        if grabbing_mouse {
            
            let rect_in_screen = window!.convertToScreen(frame)
            let centre_x = rect_in_screen.origin.x + rect_in_screen.size.width / 2.0
            let centre_y = window!.screen!.frame.size.height - (rect_in_screen.origin.y + rect_in_screen.size.height / 2.0)
            let centre_point = CGPoint(x: centre_x, y: centre_y)
            
            CGWarpMouseCursorPosition(centre_point)
            
            input.mouse_x = Float(event.deltaX)
            input.mouse_y = Float(event.deltaY)
        }
    }
    
    override func mouseEntered(with event: NSEvent)
    {
        if grabbing_mouse { NSCursor.hide() }
    }
    
    override func mouseExited(with event: NSEvent)
    {
        NSCursor.unhide()
    }
    
    // MARK: UI Changes
    
    override var acceptsFirstResponder: Bool { return true }
    
    var grabbing_mouse : Bool = false
    
    func toggle_grab_mouse ()
    {
        grabbing_mouse.toggle()
        grabbing_mouse ? NSCursor.hide() : NSCursor.unhide()

        // Move the mouse to the centre of the window
        // TODO: Save the original position and put the mouse back there when done?
        if grabbing_mouse {
            let rect_in_screen = window!.convertToScreen(frame)
            let centre_x = rect_in_screen.origin.x + rect_in_screen.size.width / 2.0
            let centre_y = window!.screen!.frame.size.height - (rect_in_screen.origin.y + rect_in_screen.size.height / 2.0)
            let centre_point = CGPoint(x: centre_x, y: centre_y)
            CGWarpMouseCursorPosition(centre_point)
        }
    }
    
}
