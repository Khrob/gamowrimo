//
//  Input.swift
//  gamo
//
//  Created by Khrob Edmonds on 11/1/19.
//  Copyright © 2019 TangoSoup. All rights reserved.
//

import Foundation
import AppKit

struct Input
{
    var up_pressed      : Bool  = false
    var down_pressed    : Bool  = false
    var left_pressed    : Bool  = false
    var right_pressed   : Bool  = false
    
    var mouse_x         : Float  = 0.0
    var mouse_y         : Float  = 0.0
    
    var mouse_down      : Bool  = false
}

var input = Input()
