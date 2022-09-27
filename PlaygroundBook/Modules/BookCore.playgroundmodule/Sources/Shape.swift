//
//  Shape.swift
//  BookCore
//
//  Created by Daniel Budd on 24/08/2016.
//  Copyright © 2016 Daniel Budd. All rights reserved.
//
import SpriteKit

public struct ShapeSK {
    public let node = SKShapeNode()
    
    public init(turtle: Tortoise){
        self.node.path = turtle.path.cgPath
        self.node.position = turtle.position
        self.node.fillColor = UIColor.clear
        self.node.strokeColor = UIColor.blue
        self.node.lineWidth = turtle.lineWidth
    }
}
