//
//  Uniforms.swift
//  gamo
//
//  Created by Khrob Edmonds on 11/1/19.
//  Copyright © 2019 TangoSoup. All rights reserved.
//

import MetalKit

struct Uniforms
{
    var time            : Float   = 0.0
    var camera          : Vector4 = Vector4()
    var camera_yaw      : Float   = 0
    var camera_pitch    : Float   = 0
    var capsule_count   : Int8    = 0
}

let Uniforms_Size   = MemoryLayout<Uniforms>.stride
var uniforms        = Uniforms()
var uniforms_buffer : MTLBuffer!

func update_uniforms ()
{
    let pointer = uniforms_buffer.contents()
    memcpy(pointer, &uniforms, Uniforms_Size)
}

func make_uniforms_buffer (_ device:MTLDevice, uniforms:inout Uniforms) -> MTLBuffer?
{
    if let buffer = device.makeBuffer(length: Uniforms_Size, options: []) { 
        let pointer = buffer.contents()
        memcpy(pointer, &uniforms, Uniforms_Size)
        return buffer
    }
    return nil
}


