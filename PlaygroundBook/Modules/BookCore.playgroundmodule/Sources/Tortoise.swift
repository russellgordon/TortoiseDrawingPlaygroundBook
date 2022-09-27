//
//  Tortoise.swift
//  BookCore
//
//  Created by Daniel Budd on 24/08/2016.
//  Modified by Russell Gordon on 18/09/2022.
//  Copyright © 2016 Daniel Budd. All rights reserved.
//

import PlaygroundSupport
import SpriteKit

public struct Tortoise {

    // MARK: Stored Properties
    public var path = UIBezierPath()
    var penColor = UIColor.blue
    var fillColor = UIColor.clear
    public var lineWidth: CGFloat = 3.0
    public var heading: Double = 0.0
    var drawing = true
    
    var position = CGPoint(x:0, y:0) {
        didSet {
            self.path.move(to: self.position)
            updateDrawing()
        }
    }
    
    // MARK: Initializers
    public init(){
        defer {
            self.position = CGPoint(x: 0, y: 0)
        }
    }

    // MARK: Functions
    
    /**
     Move the turtle forward in the direction of it's current heading.
          
     - Parameters:
         - distance: How far forward to move.
     */
    public func forward(distance: Double){
        
        let headingInRadians = self.heading * (Double.pi / 180) //convert to radians
        let dx = distance * cos(headingInRadians)
        let dy = distance * sin(headingInRadians)
        let currentX = Double(self.path.currentPoint.x)
        let currentY = Double(self.path.currentPoint.y)
        
        if drawing {
            self.path.addLine(to: CGPoint(x: currentX + dx, y: currentY + dy))
        } else {
            self.path.move(to: CGPoint(x: currentX + dx, y: currentY + dy))
        }
        self.path.stroke()
        updateDrawing()


    }
    
    /**
     Move the turtle backward, 180 degrees opposite it's current heading.
          
     - Parameters:
         - distance: How far backward to move.
     */
    public func backward(distance: Double) {
    
        self.forward(distance: -distance)
    
    }
        
    /**
     Move the turtle along a diagonal path.
          
     - Parameters:
         - dx: Desired horizontal change in position, relative to the turtle's current position.
         - dy: Desired vertical change in position, relative to the turtle's current position.
     */
    public func diagonal(dx: Double, dy: Double){
        let currentX = Double(self.path.currentPoint.x)
        let currentY = Double(self.path.currentPoint.y)
        
        if drawing {
            self.path.addLine(to: CGPoint(x: currentX + dx, y: currentY + dy))
        } else {
            self.path.move(to: CGPoint(x: currentX + dx, y: currentY + dy))
        }
        self.path.stroke()
        updateDrawing()

    }
    
    /**
     Rotate the turtle to the right (clockwise).
     
     - Parameters:
         - angle: How far to rotate the turtle to the right, in degrees.
     */
    public mutating func right(angleInDegrees angle: Double){
        self.left(angleInDegrees: -angle)
    }
    
    /**
     Rotate the turtle to the left (counter-clockwise).
     
     - Parameters:
         - angle: How far to rotate the turtle to the left, in degrees.
     */
    public mutating func left(angleInDegrees angle: Double){
        self.heading = self.heading + angle
    }
    
    /**
     Lift the pen up. When the turtle moves, no line is drawn.
     */
    public mutating func penUp() {
        self.drawing = false
    }
    
    /**
     Put the pen down. When the turtle moves, a line will be drawn.
     */
    public mutating func penDown() {
        self.drawing = true
    }
    
    /// Whether the pen is currently down, or not.
    public func isPenDown() -> Bool {
        
        return self.drawing
        
    }
    
    /// The current position of the turtle on the Cartesian plane, relative to the origin.
    public func currentPosition() -> CGPoint {
        let position = self.path.currentPoint
        
        return position
    }

    /// The current heading of the turtle on the Cartesian plane, in degrees.
    public func currentHeading() -> Double {
        return self.heading
    }
    
//    /**
//     Draw a triangle representing the turtle. The forward vertex of the triangle indicates the position of the turtle. The rear portion of the triangle indicates the heading of the turtle. For example, a triangle pointing to the right means the turtle has a heading of 0 degrees.
//     */
//    public mutating func drawSelf() {
//
//        self.penColor = UIColor.black
//        self.fillColor = UIColor.black
//        self.lineWidth = 1.0
//        self.path.addLine(to: CGPoint(x: self.position.x - 10, y: self.position.y + 5))
//        self.path.addLine(to: CGPoint(x: self.position.x, y: self.position.y - 10))
//        self.path.addLine(to: CGPoint(x: self.position.x + 10, y: self.position.y + 5))
//        self.penColor = UIColor.blue
//        self.fillColor = UIColor.clear
//        self.lineWidth = 3.0
//
//    }

        
    // Function enabling us to use drawArc() by Anders Randler
    /**
     Draw an arc, starting from the current position of the turtle.
     
     - Parameters:
         - radius: The radius of the circle, if the angle for this arc were a full 360 degrees.
         - angle: How large of an arc to make; 90 degrees is a quarter-circle, 180 is a half-circle, 360 is a full circle, and so on.
     */
    public mutating func arc(radius: Double, angle: Double){
        self.addArc(radius: radius, angle: angle)
    }
    
    /**
     Draw an arc, starting from the current position of the turtle.
     
     - Parameters:
         - radius: The radius of the circle, if the angle for this arc were a full 360 degrees.
         - angle: How large of an arc to make; 90 degrees is a quarter-circle, 180 is a half-circle, 360 is a full circle, and so on.
     */
    public mutating func addArc(radius: Double, angle: Double){
        let currentX = Double(self.path.currentPoint.x)
        let currentY = Double(self.path.currentPoint.y)
        if angle < 0 {
            let toCenterInRadians = (90 - heading) * (.pi / 180)
            let dx = radius * cos(toCenterInRadians)
            let dy = -radius * sin(toCenterInRadians)
            let centerX = currentX + dx
            let centerY = currentY + dy
            let startAngle = (90 + heading) * (.pi / 180)
            let endAngle = (90 + heading + angle) * (.pi / 180)
            heading += angle
            self.path.addArc(withCenter: CGPoint(x: centerX, y: centerY), radius: CGFloat(radius), startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: false)
        } else {
            let toCenterInRadians = (90 + heading) * (.pi / 180)
            let dx = radius * cos(toCenterInRadians)
            let dy = radius * sin(toCenterInRadians)
            let centerX = currentX + dx
            let centerY = currentY + dy
            let startAngle = (-90 + heading) * (.pi / 180)
            let endAngle = (-90 + heading + angle) * (.pi / 180)
            heading += angle
            self.path.addArc(withCenter: CGPoint(x: centerX, y: centerY), radius: CGFloat(radius), startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        }
        updateDrawing()

    }
    
    func updateDrawing() {
        
        // Background
        let view = GridPaperView()
        
        // Path
        view.add(self)
        
        // Update live view
        PlaygroundPage.current.liveView = view
        
    }
        
}


