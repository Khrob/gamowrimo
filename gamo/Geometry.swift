//
//  Geometry.swift
//  gamo
//
//  Created by Khrob Edmonds on 11/1/19.
//  Copyright © 2019 TangoSoup. All rights reserved.
//

import MetalKit

struct Capsule
{
    var start :Vector4
    var end   :Vector4
}

var capsules_buffer : MTLBuffer!

func update_capsules (_ geometry:inout [Capsule])
{
    capsules_buffer = make_capsules_buffer(render_device, geometry: &geometry)
    if capsules_buffer == nil {
        print("\(#function) - update of buffer failed")
        exit(EXIT_FAILURE)
    }
}

func make_capsules_buffer (_ device:MTLDevice, geometry:inout [Capsule]) -> MTLBuffer?
{
    if geometry.count == 0 { return nil }
    if let capsules_buffer = device.makeBuffer(length: MemoryLayout<Capsule>.stride * geometry.count, options: []) {
        let pointer = capsules_buffer.contents()
        memcpy(pointer, &geometry, MemoryLayout<Capsule>.stride * geometry.count)
        return capsules_buffer
    }
    return nil
}
