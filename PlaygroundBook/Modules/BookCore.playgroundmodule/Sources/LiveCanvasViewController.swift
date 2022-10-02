//
//  LiveCanvasViewController.swift
//  BookCore
//
//  Created by Russell Gordon on 2022-10-02.
//

import UIKit
import PlaygroundSupport

public class LiveCanvasViewController: UIViewController {
    
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
        responseLabel.textAlignment = .center
        responseLabel.translatesAutoresizingMaskIntoConstraints = true
        responseLabel.font = UIFont.boldSystemFont(ofSize: 30)
        responseLabel.adjustsFontSizeToFitWidth = true
        responseLabel.numberOfLines = 0
        gridPaper.addSubview(responseLabel)

        // Make the grid visible as a subview
        self.view.addSubview(gridPaper)
        gridPaper.bindFrameToSuperviewBounds()

    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        responseLabel.text = "Appeared"
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Center the response label
        responseLabel.bounds = view.bounds
        responseLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
    }
    
    // Add functions below to communicate with Tortoise class to draw items on the grid...
    
    /// Immediately appends new text to the label.
    public func reply(_ message: String) {
        let currentText = self.responseLabel.text ?? ""
        self.responseLabel.text = "\(currentText)\n\(message)"


        // Reset drawing if we were asked to
//        if message.contains("reset") {
//            gridPaper.turtle.startNewDrawing()
//        }
        
        // Draw something using the actual turtle
        gridPaper.turtle.diagonal(dx: Double.random(in: -100...100), dy: Double.random(in: -100...100))
        gridPaper.refreshPaths()

        
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
            
            // A text value all by itself is just part of the conversation.
            reply("\(text)")
            
            
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
            case "Echo":
                if case let .string(message)? = dictionary["Message"] {
                    reply(message)
                }
                else {
                    // We didn't have a message string in the dictionary.
                    reply("Hmm. I was told to \"Echo\" but there was no \"Message\".")
                }
            default:
                // We received a command we didn't recognize. Let's mention that.
                reply("Hmm. I don't recognize the command \"\(command)\".")
            }
        }
    }
    
}

