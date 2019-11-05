//
//  Main.swift
//  gamo
//
//  Created by Khrob Edmonds on 11/1/19.
//  Copyright © 2019 TangoSoup. All rights reserved.
//

import Foundation

var test_capsules = [
    Capsule(start: Vector4(x:   0, y: 0, z:   0, w: 0.0),   end: Vector4(x:   0, y: 3, z:   0, w: 0.10)),
    Capsule(start: Vector4(x:   0, y: 0, z:   0, w: 0.0),   end: Vector4(x:   0, y: 0, z:   6, w: 0.75)),
    Capsule(start: Vector4(x:  -4, y: 1, z:   0, w: 0.50),  end: Vector4(x:  -4, y: 3, z:   0, w: 0.50)),
    Capsule(start: Vector4(x:  10, y: 1, z: -10, w: 0.10),  end: Vector4(x:  10, y: 1, z: -10, w: 0.10)),
]

func startup ()
{
    uniforms = Uniforms(time: 0, camera: Vector4(x: 0, y: 2, z: -10, w: 1), capsule_count: Int8(test_capsules.count))
//    uniforms.camera_yaw = Float.pi / 2.0
}

func update ()
{
    respond_to_input()
    uniforms.time += 0.05
    uniforms.capsule_count = Int8(test_capsules.count)
    update_uniforms()
    update_capsules(&test_capsules)
}

func respond_to_input ()
{
    let Movement_Scale:Float = 0.5
    let Mouse_Scale:Float    = 100.0
    
    uniforms.camera_yaw   += (input.mouse_x / Mouse_Scale)
    uniforms.camera_pitch += (input.mouse_y / Mouse_Scale)
    
    uniforms.camera_pitch = min ( max (uniforms.camera_pitch, -Float.pi / 8.0), Float.pi / 8.0)
    
//    look_at.z += cos(uniforms.camera_yaw);
//    look_at.x += sin(uniforms.camera_yaw);
    
    if input.up_pressed    {
        uniforms.camera.z += cos (uniforms.camera_yaw) * Movement_Scale
        uniforms.camera.x += sin (uniforms.camera_yaw) * Movement_Scale
    }
    
    if input.down_pressed  {
        uniforms.camera.z -= cos (uniforms.camera_yaw) * Movement_Scale
        uniforms.camera.x -= sin (uniforms.camera_yaw) * Movement_Scale
    }
    
    if input.left_pressed  {
        uniforms.camera.z += sin (uniforms.camera_yaw) * Movement_Scale
        uniforms.camera.x -= cos (uniforms.camera_yaw) * Movement_Scale
    }
    
    if input.right_pressed {
        uniforms.camera.z -= sin (uniforms.camera_yaw) * Movement_Scale
        uniforms.camera.x += cos (uniforms.camera_yaw) * Movement_Scale
    }
    
}
