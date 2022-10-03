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
                    gridPaper.turtle.lineWidth = newLineWidth
                    reply("'setLineWidth' command received, line width was: \(oldLineWidth) but is now \(newLineWidth)")
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
                    gridPaper.turtle.arc(radius: radius, angle: angle)
                    reply("'arc' or 'addArc' command received with radius: \(radius), angle: \(angle)")
                } else {
                    reply("'arc or addArc' command received, but either radius or angle was not provided.")
                }
            case "startNewDrawing":
                gridPaper.turtle.startNewDrawing()
                self.debugMode = false
                self.responseLabel.text = ""
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
                                                  position: gridPaper.turtle.currentPosition(),
                                                  fillColor: gridPaper.turtle.fillColor,
                                                  strokeColor: gridPaper.turtle.penColor,
                                                  lineWidth: gridPaper.turtle.lineWidth)
                    
                    // Add to list of finished drawings
                    gridPaper.turtle.drawings.append(finishedDrawing)
                    
                    // Confirm color change
                    reply("Saved drawing with current pen and fill colors.")

                    reply("Before clearing path, position is: \(gridPaper.turtle.currentPosition())")
                    
                    // Save the current position before clearing path (position is a property of the path)
                    let currentPosition = gridPaper.turtle.currentPosition()

                    // Clear the current path
                    gridPaper.turtle.path = UIBezierPath()
                    
                    // Move new path back to current position
                    gridPaper.turtle.path.move(to: currentPosition)
                    reply("Moved turtle to \(gridPaper.turtle.currentPosition())")
                    reply("Made new drawing starting at same location as last drawing.")
                    
                    // Change the pen color
                    gridPaper.turtle.penColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    
                    // Confirm pen color change
                    reply("'setPenColor' command received, pen color changed.")
                    
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
                                                  position: gridPaper.turtle.currentPosition(),
                                                  fillColor: gridPaper.turtle.fillColor,
                                                  strokeColor: gridPaper.turtle.penColor,
                                                  lineWidth: gridPaper.turtle.lineWidth)

                    // Add to list of finished drawings
                    gridPaper.turtle.drawings.append(finishedDrawing)
                    
                    // Confirm color change
                    reply("Saved drawing with current pen and fill colors.")
                    
                    // Save the current position before clearing path (position is a property of the path)
                    let currentPosition = gridPaper.turtle.currentPosition()

                    // Clear the current path
                    gridPaper.turtle.path = UIBezierPath()
                    
                    // Move new path back to current position
                    gridPaper.turtle.path.move(to: currentPosition)
                    reply("Moved turtle to \(gridPaper.turtle.currentPosition())")
                    reply("Made new drawing starting at same location as last drawing.")

                    // Change the fill color
                    gridPaper.turtle.fillColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    
                    // Confirm fill color change
                    reply("'setFillColor' command received, fill color changed.")
                    
                } else {
                    reply("'setFillColor' command received, but one of the RGBA channels was not provided.")
                }
            default:
                // We received a command we didn't recognize. Let's mention that.
                reply("Hmm. I don't recognize the command \"\(command)\".")
            }

            // Update the drawing (remove old paths, add new ones)
            gridPaper.refreshPaths()

        }
    }
    
}

