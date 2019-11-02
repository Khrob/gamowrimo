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
    respond_to_input()
    uniforms.time += 0.05
    uniforms.capsule_count = Int8(test_capsules.count)
    let offset = 1.5 + (0.5*sin(uniforms.time))
    uniforms.camera.y = 3 - offset
    test_capsules[2].start.y = offset
    update_uniforms()
    update_capsules(&test_capsules)
}

func respond_to_input ()
{
    let Small_Amount:Float = 0.1
        
    if input.up_pressed    { uniforms.camera.z += Small_Amount }
    if input.down_pressed  { uniforms.camera.z -= Small_Amount }
    if input.left_pressed  { uniforms.camera.x += Small_Amount }
    if input.right_pressed { uniforms.camera.x -= Small_Amount }
    
    uniforms.camera.x += input.mouse_x
    uniforms.camera.z += input.mouse_y
    
}
