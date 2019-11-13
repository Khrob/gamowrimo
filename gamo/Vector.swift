//
//  Vector.swift
//  gamo
//
//  Created by Khrob Edmonds on 11/12/19.
//  Copyright © 2019 TangoSoup. All rights reserved.
//

import Foundation

struct Vector3
{
    var x : Float = 0.0
    var y : Float = 0.0
    var z : Float = 0.0
    
    init ()
    {
        x = 0; y = 0; z = 0;
    }
    
    init (_ v:Vector4)
    {
        x = v.x; y = v.y; z = v.z;
    }
    
    init (_ x: Float, _ y:Float, _ z:Float)
    {
        self.x = x; self.y = y; self.z = z;
    }
    
    var magnitude  : Float { return sqrt(x*x + y*y + z*z) }
    var normalized : Vector3 { let mag = 1.0 / self.magnitude; return Vector3(self.x * mag, self.y * mag, self.z * mag) }
}

struct Vector4
{
    var x : Float = 0.0
    var y : Float = 0.0
    var z : Float = 0.0
    var w : Float = 0.0
    
    var magnitude : Float { return sqrt(x*x + y*y + z*z + w*w) }
}

func - (lhs:Vector3, rhs:Vector3) -> Vector3
{
    return Vector3(lhs.x-rhs.x, lhs.y-rhs.y, lhs.z-rhs.z)
}

func - (lhs:Vector4, rhs:Vector4) -> Vector4
{
    return Vector4(x: lhs.x-rhs.x, y: lhs.y-rhs.y, z: lhs.z-rhs.z, w: lhs.w-rhs.w)
}

func + (lhs:Vector3, rhs:Vector3) -> Vector3
{
    return Vector3(lhs.x+rhs.x, lhs.y+rhs.y, lhs.z+rhs.z)
}

func + (lhs:Vector4, rhs:Vector4) -> Vector4
{
    return Vector4(x: lhs.x+rhs.x, y: lhs.y+rhs.y, z: lhs.z+rhs.z, w: lhs.w+rhs.w)
}

func / (lhs:Vector3, rhs:Float) -> Vector3
{
    return Vector3(lhs.x/rhs, lhs.y/rhs, lhs.z/rhs)
}

func / (lhs:Vector4, rhs:Float) -> Vector4
{
    return Vector4(x: lhs.x/rhs, y: lhs.y/rhs, z: lhs.z/rhs, w: lhs.w/rhs)
}

func * (lhs:Vector3, rhs:Float) -> Vector3
{
    return Vector3(lhs.x*rhs, lhs.y*rhs, lhs.z*rhs)
}

func * (lhs:Vector4, rhs:Float) -> Vector4
{
    return Vector4(x: lhs.x*rhs, y: lhs.y*rhs, z: lhs.z*rhs, w: lhs.w*rhs)
}

infix operator •: AdditionPrecedence
func • (lhs:Vector3, rhs:Vector3) -> Float
{
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
}
