//
//  Main.swift
//  gamo
//
//  Created by Khrob Edmonds on 11/1/19.
//  Copyright © 2019 TangoSoup. All rights reserved.
//

import Foundation

var origin_geometry = [
    Round_Cone(start: Vector4(x:   0, y: 0, z:   0, w: 0.0),   end: Vector4(x:   0, y: 3, z: 0, w: 0.10)),
    Round_Cone(start: Vector4(x:   0, y: 0, z:   0, w: 0.0),   end: Vector4(x:   3, y: 0, z: 0, w: 0.20)),
    Round_Cone(start: Vector4(x:   0, y: 0, z:   0, w: 0.0),   end: Vector4(x:   0, y: 0, z: 3, w: 0.10)),
]

struct Player
{
    var position  : Vector3
    var direction : Float
    var height    : Float
}

struct Player_Camera
{
    var vertical_angle   : Float
    var horizontal_angle : Float
    var distance         : Float
}

struct Camera
{
    var origin  : Vector3
    var lookat : Vector3
}

// MARK: Live Data

var player = Player(position: Vector3(), direction: 0, height: 1.0)
var player_camera = Player_Camera(vertical_angle: 0, horizontal_angle: 0, distance: 2.0)
var capsule_geometry:[Round_Cone] = []
var world_geometry:[Round_Cone] = []

// MARK: Main Callbacks

func startup ()
{
    uniforms = Uniforms(time: 0, camera_origin: Vector3(0, 2, -10), camera_lookat: Vector3(), capsule_count: Int8(capsule_geometry.count))
    world_geometry = generate_world_geo(30)
    capsule_geometry.removeAll()
    capsule_geometry.append(contentsOf: origin_geometry)
    update_round_cones(&capsule_geometry)
}

func update ()
{
    respond_to_input()
    uniforms.time += 0.05
    uniforms.capsule_count = Int8(capsule_geometry.count)
    
    let camera = camera_position(player, player_camera)
    uniforms.camera_origin = camera.origin
    uniforms.camera_lookat = camera.lookat
    update_uniforms()
    capsule_geometry.removeAll()
    capsule_geometry.append(contentsOf: origin_geometry)
    capsule_geometry.append(contentsOf: world_geometry)
    capsule_geometry.append(contentsOf: player_geo())
    update_round_cones(&capsule_geometry)
}

func generate_world_geo (_ count:Int) -> [Round_Cone]
{
    var capsules:[Round_Cone] = []
    let world_width:Float = 100.0
    
    for _ in 0 ... count {
        
        let x = Float(drand48() - 0.5) * world_width
        let z = Float(drand48() - 0.5) * world_width
        let r = Float(drand48() * 2.0)
        let h = Float(drand48() * 10.0)
        
        let c = Round_Cone(start: Vector4(x: x, y: r, z: z, w: r),
                        end: Vector4(x: x, y: r+h, z: z, w: r / 4.0))
        
        capsules.append(c)
    }
    return capsules
}

func player_geo () -> [Round_Cone]
{
    var player_capsules:[Round_Cone] = []
    let p_bottom = Vector4(x: player.position.x, y: player.position.y+0.25, z: player.position.z, w: 0.25)
    var p_top = p_bottom
    p_top.y += player.height
    p_top.w = 0.2
    let player_capsule = Round_Cone(start: p_bottom, end: p_top)
    var player_nose = Round_Cone(start: p_bottom, end: p_top)
    player_nose.start.y += (player.height*0.75)
    player_nose.start.w = 0.2
    player_nose.end.y   = player_nose.start.y
    player_nose.end.x   += sin(player.direction)
    player_nose.end.z   += cos(player.direction)
    player_nose.end.w = 0.1
    player_capsules.append(player_capsule)
    player_capsules.append(player_nose)
    return player_capsules
}

func respond_to_input ()
{
    let Mouse_Scale:Float    = 100.0
    let Movement_Scale:Float = 0.1
    let Turn_Scale:Float     = 30.0
    
    player_camera.vertical_angle   += (input.mouse_y / Mouse_Scale)
    player_camera.horizontal_angle += (input.mouse_x / Mouse_Scale)
    
    input.mouse_x = 0.0
    input.mouse_y = 0.0
    
    if input.left_pressed  { player.direction -= Float.pi / Turn_Scale }
    if input.right_pressed { player.direction += Float.pi / Turn_Scale }
    
    if input.up_pressed    {
        player.position.z += cos (player.direction) * Movement_Scale
        player.position.x += sin (player.direction) * Movement_Scale
    }
    
    if input.down_pressed  {
        player.position.z -= cos (player.direction) * Movement_Scale
        player.position.x -= sin (player.direction) * Movement_Scale
    }
    
//    player.position.y = 20.0
}

func camera_position (_ player:Player, _ player_camera:Player_Camera) -> Camera
{
    let look_at = Vector3(player.position.x, player.position.y + (player.height * 0.75), player.position.z)
    let camera_angle  = Float.pi + player_camera.horizontal_angle
    let camera_origin = Vector3 (
        look_at.x - sin(camera_angle) * player_camera.distance,
        look_at.y + sin (player_camera.vertical_angle) * player_camera.distance,
        look_at.z + cos(camera_angle) * player_camera.distance)
    return Camera(origin: camera_origin, lookat: look_at)
}
