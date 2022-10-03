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

public typealias Degrees = Double

public extension Degrees {
    func asRadians() -> Double {
        return self * Double.pi / 180
    }
}

public enum Role {
    case sender
    case receiver
}

public struct Tortoise {

    // MARK: Stored Properties
    public var path = UIBezierPath()
    var penColor = UIColor.blue
    var fillColor = UIColor.red
    public var lineWidth: CGFloat = 3.0 {
        didSet {
            
            // Set new line width
            messageToLiveView(action: PlaygroundValue.dictionary([
                "Command": .string("setLineWidth"),
                "from": .floatingPoint(Double(oldValue)),
                "to": .floatingPoint(Double(lineWidth))
            ]))
            
        }
    }
    public var heading: Double = 0.0 {
        didSet {
            
            // Set new heading
            messageToLiveView(action: PlaygroundValue.dictionary([
                "Command": .string("setHeading"),
                "from": .floatingPoint(oldValue),
                "to": .floatingPoint(heading)
            ]))

        }
    }
    var drawing = true
    var role: Role
    var position = CGPoint(x:0, y:0) {
        didSet {
            self.path.move(to: self.position)
        }
    }
    
    // MARK: Initializers
    public init(role: Role = .sender) {
        self.role = role
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
        self.path.fill()

        // Send command to move turtle forward
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("forward"),
            "distance": .floatingPoint(distance)
        ]))

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
        self.path.fill()
        
        // Send command to draw a diagonal line
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("diagonal"),
            "dx": .floatingPoint(dx),
            "dy": .floatingPoint(dy)
        ]))
        
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
        
        // Send command to pick up the pen
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("penUp")
        ]))

    }
    
    /**
     Put the pen down. When the turtle moves, a line will be drawn.
     */
    public mutating func penDown() {
        self.drawing = true

        // Send command to put the pen down
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("penDown")
        ]))

    }
    
    /// Whether the pen is currently down, or not.
    public func isPenDown() -> Bool {
        
        return self.drawing
        
    }
    
    /// The current position of the turtle on the Cartesian plane, relative to the origin.
    public func currentPosition() -> CGPoint {
        let position = self.path.currentPoint

        // Send command to report current position
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("reportCurrentPosition"),
            "x": .floatingPoint(position.x),
            "y": .floatingPoint(position.y)
        ]))

        return position
    }

    /// The current heading of the turtle on the Cartesian plane, in degrees.
    public func currentHeading() -> Double {
        
        // Send command to report current heading
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("reportCurrentHeading"),
            "heading": .floatingPoint(self.heading)
        ]))

        return self.heading
    }
    
    /// See developer debug mode messages
    public func toggleDebugMode() {
        
        // Send command to enable/disable debug mode messages
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("toggleDebugMode")
        ]))

    }
    
    /**
     Draw a triangle representing the turtle. The forward vertex of the triangle indicates the position of the turtle. The rear portion of the triangle indicates the heading of the turtle. For example, a triangle pointing to the right means the turtle has a heading of 0 degrees.
     */
    public mutating func drawSelf() {

        left(angleInDegrees: 150)
        forward(distance: 15)
        left(angleInDegrees: 120)
        let forwardMovement = 2.0 * 15.0 * tan(Degrees(30.0).asRadians()) * 0.866
        forward(distance: forwardMovement)
        left(angleInDegrees: 120)
        forward(distance: 15)
        right(angleInDegrees: 30)

    }

        
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
            self.path.fill()
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
            self.path.fill()
        }
        
        // Send command to update the drawing in the live view
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("arc"),
            "radius": .floatingPoint(radius),
            "angle": .floatingPoint(angle)
        ]))

    }
    
    mutating func startNewDrawing() {
        self.path = UIBezierPath()
        self.penColor = UIColor.blue
        self.fillColor = UIColor.red
        self.lineWidth = 3.0
        self.heading = 0.0
        self.drawing = true
        self.position = CGPoint(x: 0, y: 0)
        
        // Send command to start a new drawing
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("startNewDrawing")
        ]))

    }
    
    // When this is the Tortoise instance in the playground page, send messages to the Tortoise instance contained in the live view (LiveCanvasViewController)
    func messageToLiveView(action: PlaygroundValue) {
        
        if self.role == .sender {
            // Send a message to the live view so the embedded Tortoise instance actually draws what was requested
            let page = PlaygroundPage.current
            if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
                proxy.send(action)
            }
        }

    }
        
}


