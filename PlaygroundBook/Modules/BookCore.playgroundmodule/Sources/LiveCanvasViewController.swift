//
//  LiveCanvasViewController.swift
//  BookCore
//
//  Created by Russell Gordon on 2022-10-02.
//

import UIKit
import PlaygroundSupport

public class LiveCanvasViewController: UIViewController {
    
    // Whether to show messages received from the live view
    var debugMode = false

    public var gridPaper: GridPaperView!
    var responseLabel: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background
        gridPaper = GridPaperView()
        self.view.backgroundColor = .white
        gridPaper.translatesAutoresizingMaskIntoConstraints = false
        
        // Set whether to draw lines of grid
        gridPaper.shouldDrawMainLines = false
        gridPaper.shouldDrawCenterLines = false
        
                
        // Add response label to the grid
        responseLabel = UILabel()
        responseLabel.textAlignment = .left
        responseLabel.translatesAutoresizingMaskIntoConstraints = true
        responseLabel.font = UIFont.systemFont(ofSize: 12)
        responseLabel.textColor = .black
        responseLabel.adjustsFontSizeToFitWidth = true
        responseLabel.numberOfLines = 0
        gridPaper.addSubview(responseLabel)
        
        // Make the grid visible as a subview
        self.view.addSubview(gridPaper)
        gridPaper.bindFrameToSuperviewBounds()
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if debugMode {
            responseLabel.text = "Appeared"
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Center the response label
        responseLabel.bounds = view.bounds
        responseLabel.center = CGPoint(x: view.bounds.midX + 50, y: view.bounds.midY)

    }
    
    /// Immediately appends new text to the label.
    public func reply(_ message: String) {
        
        if debugMode {
            let currentText = self.responseLabel.text ?? ""
            self.responseLabel.text = "\(currentText)\n\(message)"
        }

    }
    
}

extension LiveCanvasViewController: PlaygroundLiveViewMessageHandler {
    
    public func liveViewMessageConnectionOpened() {
        // We don't need to do anything in particular when the connection opens.
    }
    
    public func liveViewMessageConnectionClosed() {
        // We don't need to do anything in particular when the connection closes.
    }
    
    public func receive(_ message: PlaygroundValue) {
        
        switch message {
        case let .string(text):
            reply("You sent this text: \(text)")
        case let .integer(number):
            reply("You sent me the number \(number)!")
        case let .boolean(boolean):
            reply("You sent me the value \(boolean)!")
        case let .floatingPoint(number):
            reply("You sent me the number \(number)!")
        case let .date(date):
            reply("You sent me the date \(date)")
        case .data:
            reply("Hmm. I don't know what to do with data values.")
        case .array:
            reply("Hmm. I don't know what to do with an array.")
        case let .dictionary(dictionary):
            
            guard case let .string(command)? = dictionary["Command"] else {
                // We received a dictionary without a "Command" key.
                reply("Hmm. I was sent a dictionary, but it was missing a \"Command\".")
                return
            }
            
            switch command {
                
            case "setLineWidth":
                if case let .floatingPoint(oldLineWidth)? = dictionary["from"],
                case let .floatingPoint(newLineWidth)? = dictionary["to"] {
                    
                    // Save the current drawing
                    let finishedDrawing = Drawing(path: gridPaper.turtle.path,
                                                  position: gridPaper.turtle.position,
                                                  fillColor: gridPaper.turtle.fillColor,
                                                  strokeColor: gridPaper.turtle.penColor,
                                                  lineWidth: gridPaper.turtle.lineWidth,
                                                  text: nil)

                    // Add to list of finished drawings
                    gridPaper.turtle.drawings.append(finishedDrawing)
                    
                    // Confirm that current drawing attributes were saved
                    reply("Saved drawing with current pen color, fill color, and line width.")
                    
                    reply("** BEFORE SETTING LINE WIDTH ** Turtle just saved is: \(dump(finishedDrawing))")

                    reply("Before clearing path, position is: \(gridPaper.turtle.currentPosition())")

                    // Save the current position before clearing path (position is a property of the path)
                    let currentPosition = gridPaper.turtle.currentPosition()

                    // Clear the current path
                    gridPaper.turtle.path = UIBezierPath()
                    
                    // Move new path back to current position
                    gridPaper.turtle.path.move(to: currentPosition)

                    // Change the line width
                    gridPaper.turtle.lineWidth = newLineWidth
                    
                    // Confirm the line width change
                    reply("'setLineWidth' command received, line width was: \(oldLineWidth) but is now \(newLineWidth)")
                    
                    // Report state of just saved turtle
                    reply("** AFTER SETTING LINE WIDTH ** Current turtle state is, path: \(gridPaper.turtle.path)\nposition: \(gridPaper.turtle.position)\n fillColor: \(gridPaper.turtle.fillColor)\n strokeColor:\(gridPaper.turtle.penColor)\nlineWidth: \(gridPaper.turtle.lineWidth)")

                    
                } else {
                    reply("'setLineWidth' command received, but no new line width was provided.")
                }
                
            case "setHeading":
                if case let .floatingPoint(oldHeading)? = dictionary["from"],
                   case let .floatingPoint(newHeading)? = dictionary["to"] {
                    gridPaper.turtle.heading = newHeading
                    reply("'setHeading' command received, heading was: \(oldHeading) but is now \(newHeading)")
                } else {
                    reply("'setHeading' command received, but no heading was provided.")
                }
                
            case "forward":
                if case let .floatingPoint(distance)? = dictionary["distance"] {
                    reply("Before forward, position is: \(gridPaper.turtle.currentPosition())")
                    gridPaper.turtle.forward(distance: distance)
                    reply("Turtle path is: \(dump(gridPaper.turtle.path))")
                    reply("After forward, position is: \(gridPaper.turtle.currentPosition())")
                    reply("'forward' command received with distance: \(distance)")
                } else {
                    reply("'forward' command received, but no distance was provided.")
                }
                
            case "diagonal":
                if case let .floatingPoint(dx)? = dictionary["dx"],
                   case let .floatingPoint(dy)? = dictionary["dy"] {
                    reply("Before diagonal, position is: \(gridPaper.turtle.currentPosition())")
                    gridPaper.turtle.diagonal(dx: dx, dy: dy)
                    reply("Turtle path is: \(dump(gridPaper.turtle.path))")
                    reply("After diagonal, position is: \(gridPaper.turtle.currentPosition())")
                    reply("'diagonal' command received with dx: \(dx), dy: \(dy)")
                } else {
                    reply("'diagonal' command received, but either dx or dy was not provided.")
                }
                
            case "penUp":
                gridPaper.turtle.penUp()
                reply("'penUp' command received.")
                
            case "penDown":
                gridPaper.turtle.penDown()
                reply("'penDown' command received.")
                
            case "reportCurrentPosition":
                if case let .floatingPoint(x)? = dictionary["x"],
                   case let .floatingPoint(y)? = dictionary["y"] {
                    reply("'reportCurrentPosition' command received, position is: (\(x), \(y))")
                } else {
                    reply("'reportCurrentPosition' command received, but either x or y value was not provided.")
                }
                
            case "reportCurrentHeading":
                if case let .floatingPoint(heading)? = dictionary["heading"] {
                    reply("'reportCurrentHeading' command received, heading is: \(heading)")
                } else {
                    reply("'reportCurrentPosition' command received, but heading was not provided.")
                }
                
            case "arc":
                if case let .floatingPoint(radius)? = dictionary["radius"],
                   case let .floatingPoint(angle)? = dictionary["angle"] {
                    
                    // Heading will have been incremented already due to didSet being activated (and sending a message to the live view) from within the addArc function from within the Tortoise instance on the Playground page
                    // So, inside the turtle here that is in the live view, we decrement the angle once to compensate
                    // This ensures that the heading is at the same value in the live view when the arc is about to be drawn, as compared to the heading on the playground page when the arc was about to be drawn
                    gridPaper.turtle.heading -= angle
                    
                    // Now draw the arc
                    gridPaper.turtle.arc(radius: radius, angle: angle)
                    
                    // Confirm that arc was drawn
                    reply("'arc' or 'addArc' command received with radius: \(radius), angle: \(angle)")
                    
                } else {
                    reply("'arc or addArc' command received, but either radius or angle was not provided.")
                }
                
            case "startNewDrawing":
                gridPaper.turtle.startNewDrawing()
                self.debugMode = false
                self.responseLabel.text = ""

            case "renderDrawingToPDF":
                self.createPDFFromView(saveToDocumentsWithFileName: "PlaygroundDrawing.pdf")
                
            case "toggleDebugMode":
                reply("'toggleDebugMode' command received. Debug mode is now: \(!self.debugMode)")
                self.debugMode.toggle()
                
            case "setPenColor":
                if case let .floatingPoint(red)? = dictionary["red"],
                   case let .floatingPoint(green)? = dictionary["green"],
                   case let .floatingPoint(blue)? = dictionary["blue"],
                   case let .floatingPoint(alpha)? = dictionary["alpha"] {
                    
                    // Save the current drawing
                    let finishedDrawing = Drawing(path: gridPaper.turtle.path,
                                                  position: gridPaper.turtle.position,
                                                  fillColor: gridPaper.turtle.fillColor,
                                                  strokeColor: gridPaper.turtle.penColor,
                                                  lineWidth: gridPaper.turtle.lineWidth,
                                                  text: nil)
                    
                    // Add to list of finished drawings
                    gridPaper.turtle.drawings.append(finishedDrawing)
                    
                    // Confirm that current drawing attributes were saved
                    reply("** BEFORE SETTING PEN COLOR ** Turtle just saved is: \(dump(finishedDrawing))")

                    reply("Before clearing path, position is: \(gridPaper.turtle.currentPosition())")
                                        
                    // Save the current position before clearing path (position is a property of the path)
                    let currentPosition = gridPaper.turtle.currentPosition()

                    // Clear the current path
                    gridPaper.turtle.path = UIBezierPath()
                    
                    // Move new path back to current position
                    gridPaper.turtle.path.move(to: currentPosition)

                    // Change the pen color
                    let newPenColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    gridPaper.turtle.penColor = newPenColor
                    
                    // Confirm pen color change
                    reply("'setPenColor' command received, pen color in gridPaper's turtle is now: \(dump(gridPaper.turtle.penColor)) -- AND -- pen color received from live view's turtle is \(dump(newPenColor))")
                    
                    // Report state of just saved turtle
                    reply("** AFTER SETTING PEN COLOR ** Current turtle state is, path: \(gridPaper.turtle.path)\nposition: \(gridPaper.turtle.position)\n fillColor: \(gridPaper.turtle.fillColor)\n strokeColor:\(gridPaper.turtle.penColor)\nlineWidth: \(gridPaper.turtle.lineWidth)")

                } else {
                    reply("'setPenColor' command received, but one of the RGBA channels was not provided.")
                }
            case "setFillColor":
                if case let .floatingPoint(red)? = dictionary["red"],
                   case let .floatingPoint(green)? = dictionary["green"],
                   case let .floatingPoint(blue)? = dictionary["blue"],
                   case let .floatingPoint(alpha)? = dictionary["alpha"] {
                    
                    // Save the current drawing
                    let finishedDrawing = Drawing(path: gridPaper.turtle.path,
                                                  position: gridPaper.turtle.position,
                                                  fillColor: gridPaper.turtle.fillColor,
                                                  strokeColor: gridPaper.turtle.penColor,
                                                  lineWidth: gridPaper.turtle.lineWidth,
                                                  text: nil)

                    // Add to list of finished drawings
                    gridPaper.turtle.drawings.append(finishedDrawing)
                    
                    // Confirm that current drawing attributes were saved
                    reply("** BEFORE SETTING FILL COLOR ** Turtle just saved is: \(dump(finishedDrawing))")
                    
                    // Save the current position before clearing path (position is a property of the path)
                    let currentPosition = gridPaper.turtle.currentPosition()

                    // Clear the current path
                    gridPaper.turtle.path = UIBezierPath()
                    
                    // Move new path back to current position
                    gridPaper.turtle.path.move(to: currentPosition)

                    // Change the fill color
                    let newFillColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    gridPaper.turtle.fillColor = newFillColor

                    // Confirm fill color change
                    reply("'setFillColor' command received, fill color in gridPaper's turtle is now: \(dump(gridPaper.turtle.fillColor)) -- AND -- fill color received from live view's turtle is \(dump(newFillColor))")
                    
                    // Report state of just saved turtle
                    reply("** AFTER SETTING FILL COLOR ** Current turtle state is, path: \(gridPaper.turtle.path)\nposition: \(gridPaper.turtle.position)\n fillColor: \(gridPaper.turtle.fillColor)\n strokeColor:\(gridPaper.turtle.penColor)\nlineWidth: \(gridPaper.turtle.lineWidth)")
                    
                } else {
                    reply("'setFillColor' command received, but one of the RGBA channels was not provided.")
                }
                
            case "drawText":
                if case let .string(message)? = dictionary["message"],
                   case let .floatingPoint(x)? = dictionary["atX"],
                   case let .floatingPoint(y)? = dictionary["atY"],
                   case let .floatingPoint(size)? = dictionary["size"],
                   case let .floatingPoint(kerning)? = dictionary["kerning"],
                   case let .floatingPoint(red)? = dictionary["red"],
                   case let .floatingPoint(green)? = dictionary["green"],
                   case let .floatingPoint(blue)? = dictionary["blue"],
                   case let .floatingPoint(alpha)? = dictionary["alpha"] {
                    
                    // Save the current drawing
                    let finishedDrawing = Drawing(path: gridPaper.turtle.path,
                                                  position: gridPaper.turtle.position,
                                                  fillColor: gridPaper.turtle.fillColor,
                                                  strokeColor: gridPaper.turtle.penColor,
                                                  lineWidth: gridPaper.turtle.lineWidth,
                                                  text: nil)

                    // Add to list of finished drawings
                    gridPaper.turtle.drawings.append(finishedDrawing)
                    
                    // Confirm that current drawing attributes were saved
                    reply("** BEFORE DRAWING TEXT ** Turtle just saved is: \(dump(finishedDrawing))")
                    
                    // Save the current position before clearing path (position is a property of the path)
                    let currentPosition = gridPaper.turtle.currentPosition()

                    // Clear the current path
                    gridPaper.turtle.path = UIBezierPath()
                    
                    // Move new path back to current position
                    gridPaper.turtle.path.move(to: currentPosition)

                    // Create the color for the text
                    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    
                    // Add a drawing with the text just received
                    let textToRender = Text(message: message,
                                            position: Point(x: x, y: y),
                                            size: size,
                                            kerning: kerning,
                                            color: color)
                    
                    // Save the drawing that contains this text to render
                    let drawingWithText = Drawing(path: gridPaper.turtle.path,
                                                  position: gridPaper.turtle.position,
                                                  fillColor: gridPaper.turtle.fillColor,
                                                  strokeColor: gridPaper.turtle.penColor,
                                                  lineWidth: gridPaper.turtle.lineWidth,
                                                  text: textToRender)

                    // Add to list of finished drawings
                    gridPaper.turtle.drawings.append(drawingWithText)
                    
                    // Confirm fill color change
                    reply("'drawText' command received")
                    
                    // Report state of just saved turtle
                    reply("** AFTER DRAWING TEXT ** Current turtle state is, path: \(gridPaper.turtle.path)\nposition: \(gridPaper.turtle.position)\n fillColor: \(gridPaper.turtle.fillColor)\n strokeColor:\(gridPaper.turtle.penColor)\nlineWidth: \(gridPaper.turtle.lineWidth)")
                    
                } else {
                    reply("'drawText' command received, but some required information was missing.")
                }
                
            case "drawRoundedRectangle":
                if case let .floatingPoint(x)? = dictionary["atX"],
                   case let .floatingPoint(y)? = dictionary["atY"],
                   case let .floatingPoint(width)? = dictionary["width"],
                   case let .floatingPoint(height)? = dictionary["height"],
                   case let .floatingPoint(cornerRadius)? = dictionary["cornerRadius"],
                   case let .boolean(anchoredAtBottomLeft)? = dictionary["anchoredAtBottomLeft"] {
                    
                    // Save the current drawing
                    let finishedDrawing = Drawing(path: gridPaper.turtle.path,
                                                  position: gridPaper.turtle.position,
                                                  fillColor: gridPaper.turtle.fillColor,
                                                  strokeColor: gridPaper.turtle.penColor,
                                                  lineWidth: gridPaper.turtle.lineWidth,
                                                  text: nil)

                    // Add to list of finished drawings
                    gridPaper.turtle.drawings.append(finishedDrawing)
                    
                    // Confirm that current drawing attributes were saved
                    reply("** BEFORE DRAWING ROUNDED RECTANGLE ** Turtle just saved is: \(dump(finishedDrawing))")
                    
                    // Save the current position before clearing path (position is a property of the path)
                    let currentPosition = gridPaper.turtle.currentPosition()

                    // Clear the current path
                    gridPaper.turtle.path = UIBezierPath()
                    
                    // Move new path back to current position
                    gridPaper.turtle.path.move(to: currentPosition)
                    
                    // Confirm command received
                    reply("'drawRoundedRectangle' command received, just about to draw it...")
                    
                    // Draw the rectangle in the turtle that's part of the live view...
                    gridPaper.turtle.drawRoundedRectangle(at: Point(x: x, y: y),
                                                          width: width,
                                                          height: height,
                                                          cornerRadius: cornerRadius,
                                                          anchoredBy: anchoredAtBottomLeft == true ? AnchorPosition.bottomLeft : AnchorPosition.centre)
                    
                    // Report state of just saved turtle
                    reply("** AFTER DRAWING ROUNDED RECTANGLE ** Current turtle state is, path: \(gridPaper.turtle.path)\nposition: \(gridPaper.turtle.position)\n fillColor: \(gridPaper.turtle.fillColor)\n strokeColor:\(gridPaper.turtle.penColor)\nlineWidth: \(gridPaper.turtle.lineWidth)")
                    
                } else {
                    reply("'drawRoundedRectangle' command received, but some required information was missing.")
                }
                
            case "drawAxes":
                if
//                    case let .boolean(withScale)? = dictionary["withScale"],
//                    case let .integer(by)? = dictionary["by"],
//                    case let .integer(width)? = dictionary["width"],
//                    case let .integer(height)? = dictionary["height"],
                    case let .floatingPoint(red)? = dictionary["red"],
                    case let .floatingPoint(green)? = dictionary["green"],
                    case let .floatingPoint(blue)? = dictionary["blue"],
                    case let .floatingPoint(alpha)? = dictionary["alpha"] {
                    
                    // Save the current drawing
                    let finishedDrawing = Drawing(path: gridPaper.turtle.path,
                                                  position: gridPaper.turtle.position,
                                                  fillColor: gridPaper.turtle.fillColor,
                                                  strokeColor: gridPaper.turtle.penColor,
                                                  lineWidth: gridPaper.turtle.lineWidth,
                                                  text: nil)

                    // Add to list of finished drawings
                    gridPaper.turtle.drawings.append(finishedDrawing)

                    // Save the current position before clearing path (position is a property of the path)
                    let currentPosition = gridPaper.turtle.currentPosition()

                    // Clear the current path
                    gridPaper.turtle.path = UIBezierPath()
                    
                    // Move new path back to current position
                    gridPaper.turtle.path.move(to: currentPosition)

                    // Create the color for the text
//                    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    let _ = UIColor(red: red, green: green, blue: blue, alpha: alpha)

                    reply("Before drawing axes...")
                    // NOTE: Need to dig into WHY we don't need to call drawAxes again here
                    //       If we don't need to do it with this method, do we need to do it anywhere? 😬
//                    gridPaper.turtle.drawAxes(withScale: withScale,
//                                              by: by,
//                                              width: width,
//                                              height: height,
//                                              color: color)
                    reply("After drawing axes...")
                } else {
                    reply("'drawingAxes' command received, but some required information was missing.")
                }

                
            case "whenSettingFill":
                if case let .floatingPoint(red)? = dictionary["red"],
                   case let .floatingPoint(green)? = dictionary["green"],
                   case let .floatingPoint(blue)? = dictionary["blue"],
                   case let .floatingPoint(alpha)? = dictionary["alpha"],
                   case let .floatingPoint(newRed)? = dictionary["newRed"],
                   case let .floatingPoint(newGreen)? = dictionary["newGreen"],
                   case let .floatingPoint(newBlue)? = dictionary["newBlue"],
                   case let .floatingPoint(newAlpha)? = dictionary["newAlpha"]
                {

                    // Change the fill color
                    let oldFillColorInLiveView = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    let newFillColorInLiveView = UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)

                    // Confirm fill color change
                    reply("'whenSettingFill' command received, old fill color in live view's turtle is currently: \(dump(oldFillColorInLiveView)) -- AND -- new fill color in live view's turtle will be: \(dump(newFillColorInLiveView)).")
                    
                } else {
                    reply("'whenSettingFill' command received, but one of the RGBA channels was not provided.")
                }

            default:
                // We received a command we didn't recognize. Let's mention that.
                reply("Hmm. I don't recognize the command \"\(command)\".")
            }

            // Update the drawing (remove old paths, add new ones)
            gridPaper.refreshPaths()
            

        }
    }
    
    // SEE: https://stackoverflow.com/a/38754196/5537362
    func createPDFFromView(saveToDocumentsWithFileName fileName: String)
    {
        // Start "recording" the PDF
        let pdfData = NSMutableData()

        // SEE: https://www.hackingwithswift.com/example-code/uikit/how-to-render-pdfs-using-uigraphicspdfrenderer
        // ... for notes on pages sizes
        let scaleFactor = 1.6
        let pageRect = CGRect(origin: CGPoint(x: -306 * scaleFactor, y: 396 * scaleFactor), size: CGSize(width: 612 * scaleFactor, height: 792 * scaleFactor))
        
        // Begin drawing the PDF
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        UIGraphicsBeginPDFPage()

        // Get a context to render in
        guard UIGraphicsGetCurrentContext() != nil else { return }
//        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }

        // Render the grid paper
//        self.gridPaper.layer.render(in: pdfContext)
//
//        // Render the axe labels
//        let midX = self.gridPaper.bounds.midX
//        let midY = self.gridPaper.bounds.midY
//        let rect = CGRect(origin: CGPoint(x: midX, y: midY), size: self.gridPaper.bounds.size)
//        self.gridPaper.drawHierarchy(in: rect, afterScreenUpdates: true)

        // Render prior paths
        for priorDrawing in self.gridPaper.turtle.drawings {
            
            if let textToRender = priorDrawing.text {
                
                // Render text
                
                // Set the line spacing to 1
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 1.0
                
                // set the Obliqueness (tilt of text) to 0.0
                let skew = 0.0
                
                // Set attributes of text
                let textAttributes: [NSAttributedString.Key : AnyObject] = [
                    NSAttributedString.Key.font: UIFont(name: "Helvetica Bold", size: textToRender.size) as AnyObject,
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.obliqueness: skew as AnyObject,
                    NSAttributedString.Key.foregroundColor: textToRender.color,
                    NSAttributedString.Key.kern: NSNumber(value: textToRender.kerning) as AnyObject
                ]
                
                // Apply the attributes to the text
                let formattedText = NSAttributedString(string: textToRender.message, attributes: textAttributes)
                
                // Draw in the current context
                let translatedPosition = CGPoint(x: textToRender.position.x - textToRender.size * 0.08,
                                                 y: textToRender.position.y * -1 - textToRender.size * 0.97)
                formattedText.draw(at: translatedPosition)
                
                
            } else {

                // Just render current path in drawing

                // SEE: https://samwize.com/2016/08/25/drawing-images-with-uibezierpath/
                // Set path
                let path = priorDrawing.path
                
                // Transform the path so it is rotated correctly
                let rotation = CGAffineTransform(rotationAngle: CGFloat.pi)
                path.apply(rotation)
                
                // Horizontally flip the path
                let flip = CGAffineTransform(scaleX: -1, y: 1)
                path.apply(flip)

                // Set line width of path
                path.lineWidth = priorDrawing.lineWidth
                // Set current fill color in this drawing context
                priorDrawing.fillColor.setFill()
                // Set current stroke color in this drawing context
                priorDrawing.strokeColor.setStroke()
                // Set end cap and join style
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                // Now fill and stroke the path
                path.fill()
                path.stroke()
            }
            
        }
        
        // Now render the final path in the drawing
        // SEE: https://samwize.com/2016/08/25/drawing-images-with-uibezierpath/
        // Set path
        let path = self.gridPaper.turtle.path
        
        // Transform the path so it is rotated correctly
        let rotation = CGAffineTransform(rotationAngle: CGFloat.pi)
        path.apply(rotation)
        
        // Horizontally flip the path
        let flip = CGAffineTransform(scaleX: -1, y: 1)
        path.apply(flip)
        
        // Set line width of path
        path.lineWidth = self.gridPaper.turtle.lineWidth
        // Set current fill color in this drawing context
        self.gridPaper.turtle.fillColor.setFill()
        // Set current stroke color in this drawing context
        self.gridPaper.turtle.penColor.setStroke()
        // Set end cap and join style
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        // Now fill and stroke the path
        path.fill()
        path.stroke()

        // Stop "recording" the PDF
        UIGraphicsEndPDFContext()
        
        // Undo the rotation in the path shown on screen
        let reverseRotation = CGAffineTransform(rotationAngle: -CGFloat.pi)
        path.apply(reverseRotation)
        
        // Undo the horizontal flip by applying it again
        path.apply(flip)

        // Save the PDF
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            debugPrint(documentsFileName)
            pdfData.write(toFile: documentsFileName, atomically: true)
        }
        
        // Now reverse the changes to the other paths in the drawing...
        for priorDrawing in self.gridPaper.turtle.drawings {
            
            
            // Set path
            let path = priorDrawing.path
            
            // Undo the rotation in the path shown on screen
            let reverseRotation = CGAffineTransform(rotationAngle: -CGFloat.pi)
            path.apply(reverseRotation)
            
            // Horizontally flip the path
            let flip = CGAffineTransform(scaleX: -1, y: 1)
            path.apply(flip)

        }
        
    }
    
}

