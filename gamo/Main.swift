//
//  Main.swift
//  gamo
//
//  Created by Khrob Edmonds on 11/1/19.
//  Copyright © 2019 TangoSoup. All rights reserved.
//

import Foundation

var test_capsules = [
    Capsule(start: Vector4(x: -2, y: 1, z: 6, w: 0.50), end: Vector4(x: -2, y: 3, z: 6, w: 0.25)),
    Capsule(start: Vector4(x:  0, y: 1, z: 6, w: 0.50), end: Vector4(x:  0, y: 3, z: 6, w: 0.75)),
    Capsule(start: Vector4(x:  2, y: 1, z: 6, w: 0.50), end: Vector4(x:  2, y: 3, z: 6, w: 0.10))
]

func startup ()
{
    uniforms = Uniforms(time: 0, camera: Vector4(x: 1, y: 2, z: 3, w: 4), capsule_count: Int8(test_capsules.count))
}

func update ()
{
    uniforms.time += 0.05
    uniforms.capsule_count = Int8(test_capsules.count)
    uniforms.camera = Vector4(x: 0, y: 1.1 + sin(uniforms.time), z: -1, w: 1)
    update_uniforms()
}
