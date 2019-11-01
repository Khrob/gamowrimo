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
    var time            : Float
    var camera          : Vector4
    var capsule_count   : Int8
}

let Uniforms_Size   = MemoryLayout<Uniforms>.stride
var uniforms_buffer : MTLBuffer!
var uniforms        : Uniforms!

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


