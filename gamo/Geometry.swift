//
//  Geometry.swift
//  gamo
//
//  Created by Khrob Edmonds on 11/1/19.
//  Copyright © 2019 TangoSoup. All rights reserved.
//

import MetalKit

struct Round_Cone
{
    var start     : Vector4    // Start Sphere
    var end       : Vector4    // End Sphere
    
    var bs_centre : Vector3    // Centre of the whole thing
    var bs_radius : Float      // Bounding radius
    
    init (start s:Vector4, end e:Vector4)
    {
        start      = s
        end        = e
        let delta  = Vector3(s - e)
        let length = (delta.magnitude + s.w + e.w) / 2.0
        let normal = delta.normalized
        bs_centre  = Vector3(s) + normal * length
        bs_radius  = length / 2.0
    }
}


var round_cone_buffer : MTLBuffer!

func update_round_cones (_ geometry:inout [Round_Cone])
{
    round_cone_buffer = make_round_cones_buffer(render_device, geometry: &geometry)
    if round_cone_buffer == nil {
        print("\(#function) - update of buffer failed")
        exit(EXIT_FAILURE)
    }
}

func make_round_cones_buffer (_ device:MTLDevice, geometry:inout [Round_Cone]) -> MTLBuffer?
{
    if geometry.count == 0 { return nil }
    if let capsules_buffer = device.makeBuffer(length: MemoryLayout<Round_Cone>.stride * geometry.count, options: []) {
        let pointer = capsules_buffer.contents()
        memcpy(pointer, &geometry, MemoryLayout<Round_Cone>.stride * geometry.count)
        return capsules_buffer
    }
    return nil
}
