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

/// Used to specify how rectangles should be anchored
public enum AnchorPosition : Int {
    case bottomLeft  = 1
    case centre = 2
}

public struct Text {
    let message: String
    let position: Point
    let size: Double
    let kerning: Double
    let color: UIColor
}

public struct Drawing {
    let path: UIBezierPath
    let position: CGPoint
    let fillColor: UIColor
    let strokeColor: UIColor
    let lineWidth: CGFloat
    let text: Text?
}

public struct Tortoise {

    // MARK: Stored Properties
    public var path = UIBezierPath()
    public var drawings: [Drawing] = []
    public var penColor = UIColor.blue {
        didSet {
            
            // SEE: https://www.hackingwithswift.com/example-code/uicolor/how-to-read-the-red-green-blue-and-alpha-color-components-from-a-uicolor
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            penColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // Send message to set new pen color
            messageToLiveView(action: PlaygroundValue.dictionary([
                "Command": .string("setPenColor"),
                "red": .floatingPoint(red),
                "green": .floatingPoint(green),
                "blue": .floatingPoint(blue),
                "alpha": .floatingPoint(alpha)
            ]))
            
            if role == .sender {
                // Save the current position before clearing path (position is a property of the path)
                let currentPosition = self.currentPosition()

                // Clear the current path
                self.path = UIBezierPath()
                
                // Move new path back to current position
                self.path.move(to: currentPosition)
            }
                        
        }
    }
    public var fillColor = UIColor.clear {
        
        willSet {
            
            // DEBUG: What was the old fill color?
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            fillColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

            // DEBUG: What is the new fill color?
            var newRed: CGFloat = 0
            var newGreen: CGFloat = 0
            var newBlue: CGFloat = 0
            var newAlpha: CGFloat = 0
            newValue.getRed(&newRed, green: &newGreen, blue: &newBlue, alpha: &newAlpha)

            // Send message to set new pen color
            messageToLiveView(action: PlaygroundValue.dictionary([
                "Command": .string("whenSettingFill"),
                "red": .floatingPoint(red),
                "green": .floatingPoint(green),
                "blue": .floatingPoint(blue),
                "alpha": .floatingPoint(alpha),
                "newRed": .floatingPoint(newRed),
                "newGreen": .floatingPoint(newGreen),
                "newBlue": .floatingPoint(newBlue),
                "newAlpha": .floatingPoint(newAlpha),
            ]))
            
        }
        
        didSet {
            
            // SEE: https://www.hackingwithswift.com/example-code/uicolor/how-to-read-the-red-green-blue-and-alpha-color-components-from-a-uicolor
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            fillColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            if role == .sender {
                // Save the current position before clearing path (position is a property of the path)
                let currentPosition = self.currentPosition()

                // Clear the current path
                self.path = UIBezierPath()
                
                // Move new path back to current position
                self.path.move(to: currentPosition)
            }
            
            // Send message to set new pen color
            messageToLiveView(action: PlaygroundValue.dictionary([
                "Command": .string("setFillColor"),
                "red": .floatingPoint(red),
                "green": .floatingPoint(green),
                "blue": .floatingPoint(blue),
                "alpha": .floatingPoint(alpha)
            ]))
            
        }
        
    }
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
        
        // Send command to move turtle forward
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("forward"),
            "distance": .floatingPoint(distance)
        ]))

    }
    
    /**
     Draw some text at the given position.
          
     - Parameters:
         - message: The text to be drawn on screen.
         - at: Text will be drawn starting at this location.
         - size: The size of the text, specified in points.
         - kerning: The spacing between letters of the text. 0.0 is neutral, negative values draw letters together, positive values move letters further apart.
     */
    public func drawText(message: String, at: Point, color: UIColor = .black, size: Double = 24, kerning : Double = 0.0) {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                
        // Send command to draw text at provided position
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("drawText"),
            "message": .string(message),
            "atX": .floatingPoint(at.x),
            "atY": .floatingPoint(at.y),
            "size": .floatingPoint(size),
            "kerning": .floatingPoint(kerning),
            "red": .floatingPoint(red),
            "green": .floatingPoint(green),
            "blue": .floatingPoint(blue),
            "alpha": .floatingPoint(alpha)
        ]))

    }
    
    /**
     Draw an arc based upon the specified center point.
     
     - Parameters:
     - withCenter: The center point of the circle used to define the arc.
     - radius: The radius of the circle used to define the arc.
     - startAngle: Starting angle of the arc, measured in degrees counterclockwise from the x-axis.
     - endAngle: Ending angle of the arc, measured in degrees counterclockwise from the x-axis.
     - clockwise: Whether to draw the arc instead in a clockwise direction; default is false.
     */
    public mutating func drawArc(withCenter center: Point,
                    radius: Double,
                    startAngle: Degrees,
                    endAngle: Degrees,
                    clockwise: Bool = false) {
        
        // Define the arc
        let arc = UIBezierPath(arcCenter: center,
                               radius: radius,
                               startAngle: startAngle.asRadians(),
                               endAngle: endAngle.asRadians(),
                               clockwise: !clockwise)
        
        // Add to the existing path
        path.append(arc)

        // Send command to draw arc at given position
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("drawArc"),
            "centerX": .floatingPoint(center.x),
            "centerY": .floatingPoint(center.y),
            "radius": .floatingPoint(radius),
            "startAngle": .floatingPoint(startAngle),
            "endAngle": .floatingPoint(endAngle),
            "clockwise": .boolean(clockwise)
        ]))
        
    }
    
    /**
     Draw a bezier curve between the provided points.
     
     - Parameters:
     - from: Starting position of the curve
     - to: Ending position of the curve
     - showControlPoints: Optionally display the co-ordinates of key points and the "handles" for the curve.
     
     */
    public mutating func drawCurve(from: Point,
                          to: Point,
                          control1: Point,
                          control2: Point,
                          showControlPoints: Bool = false) {
        
        // Start a new path
        let curve = UIBezierPath()
        
        // Move to start of curve
        curve.move(to: from)
        
        // Draw the co-ordinates and "handles" of the curve
        // NOTE: If we also show the control points when running
        //       this code in the receiver then they get drawn in the wrong color.
        //       Something to investigate there but for now the workaround is to draw
        //       the control points once, from the sender (the turtle that is not in the live view)
        if showControlPoints && role == .sender {
            
            // From
            self.drawText(message: "(\(from.x), \(from.y))",
                          at: Point(x: from.x - 30, y: from.y + 5), size: 10)
            
            // To
            self.drawText(message: "(\(to.x), \(to.y))",
                          at: Point(x: to.x - 30, y: to.y + 5), size: 10)
            
            // Control 1
            self.drawText(message: "(\(control1.x), \(control1.y))",
                          at: Point(x: control1.x - 30, y: control1.y + 5), size: 10)
            
            // Control 2
            self.drawText(message: "(\(control2.x), \(control2.y))",
                          at: Point(x: control2.x - 30, y: control2.y + 5), size: 10)
            
            // Save current line width and pen color
            let originalLineWidth = self.lineWidth
            
            // Save current turtle pen color
            let originalPenColor = self.penColor

            // Set new line width and pen color for drawing handles
            self.lineWidth = 1
            self.penColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
            
            // First handle
            self.drawLine(from: Point(x: control1.x, y: control1.y),
                          to: Point(x: from.x, y: from.y))
            
            // Second handle
            self.drawLine(from: Point(x: to.x, y: to.y),
                          to: Point(x: control2.x, y: control2.y))
            
            // Return to original line width and color
            self.lineWidth = originalLineWidth
            self.penColor = originalPenColor
            
        }
        
        // Actually draw the curve
        curve.addCurve(to: CGPoint(x: to.x, y: to.y),
                       controlPoint1: control1,
                       controlPoint2: control2)
        
        // Append curve to existing path
        path.append(curve)
        
        // Send command to draw axes at provided position
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("drawCurve"),
            "fromX": .floatingPoint(from.x),
            "fromY": .floatingPoint(from.y),
            "toX": .floatingPoint(to.x),
            "toY": .floatingPoint(to.y),
            "control1X": .floatingPoint(control1.x),
            "control1Y": .floatingPoint(control1.y),
            "control2X": .floatingPoint(control2.x),
            "control2Y": .floatingPoint(control2.y),
            "showControlPoints": .boolean(showControlPoints),
        ]))
        
    }
    
    /**
     Draw an ellipse centred at the point specified.
     
     - Parameters:
         - at: Point over which the ellipse will be drawn.
         - width: How wide the ellipse will be across its horizontal axis.
         - height: How tall the ellipse will be across its vertical axis.
     */
    public func drawEllipse(at: Point,
                              width: Double,
                            height: Double) {
                
        // Create the ellipse
        let ellipse = UIBezierPath(ovalIn: CGRect(x: at.x - width / 2,
                                                  y: at.y - height / 2,
                                                  width: width,
                                                  height: height))
        
        // Add to the existing path
        path.append(ellipse)

        // Send command to draw rectangle at provided position
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("drawEllipse"),
            "atX": .floatingPoint(at.x),
            "atY": .floatingPoint(at.y),
            "width": .floatingPoint(width),
            "height": .floatingPoint(height)
        ]))
    }
    

    /**
     Draw a rectangle at the specified point and anchor position.
          
     - Parameters:
        - at: Point at which the rectangle will be drawn.
        - width: How wide the rectangle will be across its horizontal axis.
        - height: How tall the rectangle will be across its vertical axis.
        - anchoredBy: Draw the rectangle from a point at the rectangle's bottom left corner, or, the rectangle's centre.
     */
    public func drawRectangle(at: Point,
                              width: Double,
                              height: Double,
                              anchoredBy : AnchorPosition = AnchorPosition.bottomLeft) {
        
        // Set anchor co-ordinate
        var bottomLeftX = at.x
        var bottomLeftY = at.y

        // Adjust when anchored at centre point
        if anchoredBy == .centre {
            bottomLeftX = at.x - width / 2
            bottomLeftY = at.y - height / 2
        }
        
        // Create the rectangle
        let rectangle = UIBezierPath(rect: CGRect(x: bottomLeftX,
                                                  y: bottomLeftY,
                                                  width: width,
                                                  height: height))
        
        // Add to the existing path
        path.append(rectangle)

        // Send command to draw rectangle at provided position
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("drawRectangle"),
            "atX": .floatingPoint(at.x),
            "atY": .floatingPoint(at.y),
            "width": .floatingPoint(width),
            "height": .floatingPoint(height),
            "anchoredAtBottomLeft": .boolean(anchoredBy == .bottomLeft ? true : false)
        ]))
    }
    
    /**
     Draw a rounded rectangle at the specified point and anchor position.
     
     A `cornerRadius` of 25 each means that the last 25 points of a typical rectangle's corner will be replaced with the rounded edge of a circle with a radius of 25 points.
     
     - Parameters:
        - at: Point at which the rectangle will be drawn.
        - width: How wide the rectangle will be across its horizontal axis.
        - height: How tall the rectangle will be across its vertical axis.
        - cornerRadius: Size of the rounded corner.
        - anchoredBy: Draw the rectangle from a point at the rectangle's bottom left corner, or, the rectangle's centre.
     */
    public func drawRoundedRectangle(at: Point,
                                     width: Double,
                                     height: Double,
                                     cornerRadius: Double = 10,
                                     anchoredBy : AnchorPosition = AnchorPosition.bottomLeft) {
     

        // Set anchor co-ordinate
        var bottomLeftX = at.x
        var bottomLeftY = at.y

        // Adjust when anchored at centre point
        if anchoredBy == .centre {
            bottomLeftX = at.x - width / 2
            bottomLeftY = at.y - height / 2
        }
        
        // Create the rounded rectangle
        let roundedRectangle = UIBezierPath(roundedRect: CGRect(x: bottomLeftX,
                                                                y: bottomLeftY,
                                                                width: width,
                                                                height: height),
                                            cornerRadius: cornerRadius)
        
        // Add to the existing path
        path.append(roundedRectangle)

        // Send command to draw rounded rectangle at provided position
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("drawRoundedRectangle"),
            "atX": .floatingPoint(at.x),
            "atY": .floatingPoint(at.y),
            "width": .floatingPoint(width),
            "height": .floatingPoint(height),
            "cornerRadius": .floatingPoint(cornerRadius),
            "anchoredAtBottomLeft": .boolean(anchoredBy == .bottomLeft ? true : false)
        ]))
        
    }
    
    /**
     Draws horizontal and vertical axes on the canvas.
          
     - Parameters:
         - withScale: Whether to show grid lines and a scale.
         - by: How frequently to mark the change in scale.
         - width: The width of the first quadrant.
         - height: The height of the first quadrant.
         - color: The color to draw the axes with.
     */
    public mutating func drawAxes(withScale: Bool = false, by: Int = 50, width: Int, height: Int, color: UIColor) {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Save current position
        let originalPosition = self.position
        
        // Save current canvas line width
        let originalLineWidth = self.lineWidth
        self.lineWidth = 1
        
        // Save current turtle pen color
        let originalPenColor = self.penColor
                
        // Change to color provided by user
        self.penColor = UIColor(red: red, green: green, blue: blue, alpha: alpha / 2)

        // Draw horizontal axis, opaque
        self.lineWidth = 2
        self.drawLine(from: Point(x: width * -1, y: 0), to: Point(x: width, y: 0))
        
        // Draw vertical axis, opaque
        self.drawLine(from: Point(x: 0, y: height * -1), to: Point(x: 0, y: height))

        // Determine horizontal start and end points
        let horizontalStart = width / by * -1
        let horizontalEnd = horizontalStart * -1

        // Determine vertical start and end points
        let verticalStart = height / by * -1
        let verticalEnd = verticalStart * -1

        // Draw labels, opaque
        self.drawText(message: "x", at: Point(x: horizontalEnd * by - 10, y: -15), color: color, size: 12)
        self.drawText(message: "y", at: Point(x: 5, y: verticalEnd * by - 20), color: color, size: 12)

        // Draw scale if requested, opaque
        self.lineWidth = 1
        if withScale {
            
            // Skip labelling every stop on the axis if the value is small
            var labellingStep = by
            if by < 50 {
                labellingStep = by * 2
            }
            if labellingStep < 25 {
                labellingStep *= 2
            }
            
            // Draw horizontal scale and grid
            for x in stride(from: horizontalStart * by, through: horizontalEnd * by, by: by) {
                
                // Scale
                if x != 0 && x.quotientAndRemainder(dividingBy: labellingStep).remainder == 0 {
                    var offset = 0
                    if x <= -100 {
                        offset = -12
                    } else if x > -100 && x <= 0 {
                        offset = -9
                    } else if x > 0 && x < 100 {
                        offset = -7
                    } else if x >= 100 && x < 1000 {
                        offset = -9
                    }
                    self.drawText(message: "\(x)", at: Point(x: x + offset, y: 5), color: color, size: 10)
                }
                
                // Grid
//                self.drawLine(from: Point(x: x, y: height * -1), to: Point(x: x, y: height), dashed: true)
                self.drawLine(from: Point(x: x, y: height * -1), to: Point(x: x, y: height))
            }

            // Draw vertical scale and grid
            for y in stride(from: verticalStart * by, through: verticalEnd * by, by: by) {
                
                // Scale
                if y != 0 && y != verticalEnd * by && y.quotientAndRemainder(dividingBy: labellingStep).remainder == 0 {
                    self.drawText(message: "\(y)", at: Point(x: 5, y: y - 7), color: color,  size: 10)
                }
                
                // Grid
                self.drawLine(from: Point(x: width * -1, y: y), to: Point(x: width, y: y))
//                self.drawLine(from: Point(x: width * -1, y: y), to: Point(x: width, y: y), dashed: true)
            }
            

        }
        
        // Restore pen color and width
        self.penColor = originalPenColor
        self.lineWidth = originalLineWidth

        // Restore turtle to position it was in before grid was drawn
        self.penUp()
        self.diagonal(dx: originalPosition.x - self.currentPosition().x,
                      dy: originalPosition.y - self.currentPosition().y)
        self.penDown()
        
        
        // Send command to draw axes at provided position
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("drawAxes"),
            "withScale": .boolean(withScale),
            "by": .integer(by),
            "width": .integer(width),
            "height": .integer(height),
            "red": .floatingPoint(red),
            "green": .floatingPoint(green),
            "blue": .floatingPoint(blue),
            "alpha": .floatingPoint(alpha)
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
    
    /// Save a PDF of the current drawing
    public func renderDrawingToPDF() {
        
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("renderDrawingToPDF")
        ]))

    }
    
    /**
     Draw a triangle representing the turtle. The forward vertex of the triangle indicates the position of the turtle. The rear portion of the triangle indicates the heading of the turtle. For example, a triangle pointing to the right means the turtle has a heading of 0 degrees.
     */
    public mutating func drawSelf() {

        // Save current pen state
        let originalPenLiftState = self.drawing
//        let originalPenColor = self.penColor
//        let originalFillColor = self.fillColor
//        let originalLineWidth = self.lineWidth
        
        // Put pen down
        self.penDown()
        
        // Change to new values to draw turtle
//        self.penColor = .blue
//        self.fillColor = .yellow
//        self.lineWidth = 3
                
        left(angleInDegrees: 150)
        forward(distance: 15)
        left(angleInDegrees: 120)
        let forwardMovement = 2.0 * 15.0 * tan(Degrees(30.0).asRadians()) * 0.866
        forward(distance: forwardMovement)
        left(angleInDegrees: 120)
        forward(distance: 15)
        right(angleInDegrees: 30)
        
        // Restore current pen state
        if originalPenLiftState == false && self.drawing == true {
            self.penUp()
        }
        
        // Restore drawing state
//        self.penColor = originalPenColor
//        self.fillColor = originalFillColor
//        self.lineWidth = originalLineWidth

    }

        
    // Function enabling us to use drawArc() by Anders Randler
    /**
     Draw an arc, starting from the current position of the turtle.
     
     - Parameters:
         - radius: The radius of the circle, if the angle for this arc were a full 360 degrees.
         - angle: How large of an arc to make; 90 degrees is a quarter-circle, 180 is a half-circle, 360 is a full circle, and so on.
     */
    public mutating func arc(radius: Double, angle: Double) {
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
        
        // Send command to update the drawing in the live view
        messageToLiveView(action: PlaygroundValue.dictionary([
            "Command": .string("arc"),
            "radius": .floatingPoint(radius),
            "angle": .floatingPoint(angle)
        ]))

    }
    
    mutating func startNewDrawing() {
        
        self.drawings = []
        self.path = UIBezierPath()
        self.penColor = UIColor.blue
        self.fillColor = UIColor.clear
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

// Canvas-like enhancements to the Tortoise

public typealias Point = CGPoint

extension Tortoise {
    
    public mutating func drawLine(from: Point, to: Point) {
        
        // Pick the pen up
        self.penUp()
        
        // Go to the start of the line
        self.diagonal(dx: from.x - self.currentPosition().x, dy: from.y - self.currentPosition().y)
        
        // Pen down
        self.penDown()
        
        // Draw the line
        self.diagonal(dx: to.x - from.x, dy: to.y - from.y)
        
    }
    
}
