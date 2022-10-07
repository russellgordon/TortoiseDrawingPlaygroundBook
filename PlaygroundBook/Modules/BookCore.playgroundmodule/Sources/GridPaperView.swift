//
//  GridPaperView.swift
//  BookCore
//
//  Created by Luke Durrant on 17/02/2017.
//  Copyright © 2017 Squidee. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

public class GridPaperView : UIView {
    
    let xAxisLabel = GridPaperView.axisFactory(text: "X-Axis")
    let yAxisLabel = GridPaperView.axisFactory(text: "Y-Axis")
    
    let scene = CanvasScene()
    
    public var turtle = Tortoise(role: .receiver)
    
    public var shouldDrawMainLines: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var shouldDrawCenterLines: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var gridStrideSize: CGFloat = 20.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var majorGridColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var minorGridColor: UIColor = .blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var gridLineWidth: CGFloat = 0.2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        self.contentMode = .redraw
        self.backgroundColor = .white //change to .clear
        
        self.scene.scaleMode = .resizeFill
        self.scene.backgroundColor = .clear
        self.scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let viewSK: SKView = SKView()
        viewSK.allowsTransparency = true
        viewSK.backgroundColor = .clear
        viewSK.presentScene(scene)
        
        self.addSubview(viewSK)
        
        viewSK.bindFrameToSuperviewBounds()
        
        self.scene.addChild(self.xAxisLabel)
        self.scene.addChild(self.yAxisLabel)
    }
        
    public func refreshPaths() {
        
        // Remove old turtle path(s) from scene
        self.scene.removeAllChildren()
        
        // TEST: Add a variety of paths and verify that strokes and fills work as expected
        
//        let circleOnePath = CGMutablePath()
//        circleOnePath.addArc(center: CGPoint.zero,
//                             radius: 100,
//                             startAngle: 0,
//                             endAngle: CGFloat.pi * 2,
//                             clockwise: true)
//        let circleOne = SKShapeNode(path: circleOnePath)
//        circleOne.lineWidth = 10
//        circleOne.fillColor = .purple
//        circleOne.strokeColor = .orange
//        self.scene.addChild(circleOne)
//
//        let circleTwoPath = CGMutablePath()
//        circleTwoPath.addArc(center: CGPoint(x: 200, y: 200),
//                             radius: 50,
//                             startAngle: 0,
//                             endAngle: CGFloat.pi * 2,
//                             clockwise: true)
//        let circleTwo = SKShapeNode(path: circleTwoPath)
//        circleTwo.lineWidth = 5
//        circleTwo.fillColor = .yellow
//        circleTwo.strokeColor = .blue
//        self.scene.addChild(circleTwo)
//
//        let polygonOnePath = CGMutablePath()
//        polygonOnePath.move(to: CGPoint(x: 100, y: -100))
//        polygonOnePath.addLine(to: CGPoint(x: 100, y: -200))
//        polygonOnePath.addLine(to: CGPoint(x: 200, y: -200))
//        polygonOnePath.addLine(to: CGPoint(x: 200, y: -100))
//        polygonOnePath.addLine(to: CGPoint(x: 100, y: -100))
//        let polygonOne = SKShapeNode(path: polygonOnePath)
//        polygonOne.lineWidth = 4
//        polygonOne.strokeColor = .green
//        polygonOne.fillColor = .lightGray
//        self.scene.addChild(polygonOne)
//
//        let reportingLabel = SKLabelNode(text: "Path for first rectangle is:\n\(String(describing: polygonOne.path))")
//        reportingLabel.fontSize = 16
//        reportingLabel.fontColor = SKColor.black
//        self.scene.addChild(reportingLabel)
//
//        let polygonTwoPath = CGMutablePath()
//        polygonTwoPath.move(to: CGPoint(x: -100, y: -100))
//        polygonTwoPath.addLine(to: CGPoint(x: -100, y: -200))
//        polygonTwoPath.addLine(to: CGPoint(x: -200, y: -200))
//        polygonTwoPath.addLine(to: CGPoint(x: -200, y: -100))
//        polygonTwoPath.addLine(to: CGPoint(x: -100, y: -100))
//        let polygonTwo = SKShapeNode(path: polygonTwoPath)
//        polygonTwo.lineWidth = 10
//        polygonTwo.strokeColor = .red
//        polygonTwo.fillColor = .black
//        self.scene.addChild(polygonTwo)

        
        if !self.turtle.drawings.isEmpty {

        // Save current state of turtle
            let currentDrawing = Drawing(path: self.turtle.path,
                                         position: self.turtle.currentPosition(),
                                         fillColor: self.turtle.fillColor,
                                         strokeColor: self.turtle.penColor,
                                         lineWidth: self.turtle.lineWidth)

            // Iterate over prior drawings and add shapes
            for priorDrawing in self.turtle.drawings {

                // Restore properties of prior drawing
//                self.turtle.position = priorDrawing.position
//                self.turtle.path = priorDrawing.path
//                self.turtle.path.move(to: self.turtle.position)
//                self.turtle.fillColor = priorDrawing.fillColor
//                self.turtle.penColor = priorDrawing.strokeColor
//                self.turtle.lineWidth = priorDrawing.lineWidth

                // Add prior drawing back to scene
                let layer = SKShapeNode(path: priorDrawing.path.cgPath)
                layer.lineWidth = priorDrawing.lineWidth
                layer.fillColor = priorDrawing.fillColor
                layer.strokeColor = priorDrawing.strokeColor
                self.scene.addChild(layer)
            }

            // Restore current state of turtle
//            self.turtle.position = currentDrawing.position // GAHH THIS LINE WAS THE CULPRIT!
            self.turtle.path = currentDrawing.path
//            self.turtle.path.move(to: self.turtle.position)
            self.turtle.lineWidth = currentDrawing.lineWidth
            self.turtle.fillColor = currentDrawing.fillColor
            self.turtle.penColor = currentDrawing.strokeColor

        }

        // Now render the current drawing
        let layer = SKShapeNode(path: self.turtle.path.cgPath)
        layer.lineWidth = self.turtle.lineWidth
        layer.fillColor = self.turtle.fillColor
        layer.strokeColor = self.turtle.penColor
        self.scene.addChild(layer)

        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        //This is if we're loading from a nib we don't need this lets not implement it
        fatalError("init(coder:) has not been implemented")
    }
    
    public func toggleAxisLabels() {
        self.xAxisLabel.isHidden = !self.xAxisLabel.isHidden
        self.yAxisLabel.isHidden = !self.yAxisLabel.isHidden
    }
    
    override public func draw(_ rect: CGRect) {
        
        if self.shouldDrawMainLines {
            //Split this up so we could technically just draw a corner if needed
            drawGridLinesFor(axis: .x, direction: .back, dirtyRect: rect)
            drawGridLinesFor(axis: .x, direction: .forward, dirtyRect: rect)
            
            drawGridLinesFor(axis: .y, direction: .back, dirtyRect: rect)
            drawGridLinesFor(axis: .y, direction: .forward, dirtyRect: rect)
        }
        
        if self.shouldDrawCenterLines {
            self.drawMiddleLines(dirtyRect: rect)
        }
        
        self.xAxisLabel.position = CGPoint(x: (rect.midX - 30), y: -15)
        self.yAxisLabel.position = CGPoint(x: -30, y: (rect.midY - 20))
    }
    
    private func drawMiddleLines(dirtyRect: CGRect) {
        majorGridColor.set()
        
        //Draw X line
        let bezierPathX = UIBezierPath()
        bezierPathX.move(to: CGPoint(x: dirtyRect.midX, y: 0))
        bezierPathX.addLine(to: CGPoint(x: dirtyRect.midX, y: dirtyRect.maxY))
        
        bezierPathX.lineWidth = (self.gridLineWidth * 2)
        bezierPathX.stroke()
        
        //Draw Y line
        let bezierPathY = UIBezierPath()
        bezierPathY.move(to: CGPoint(x: 0, y: dirtyRect.midY))
        bezierPathY.addLine(to: CGPoint(x: dirtyRect.maxX, y: dirtyRect.midY))
        
        bezierPathY.lineWidth = (self.gridLineWidth * 2)
        bezierPathY.stroke()
    }
    
    //THis should probably be in another file in the real world called something like SKLabelNodeFactory but because we're only in playground its probably ok
    private static func axisFactory(text: String) -> SKLabelNode {
        
        //label for axis
        let label: SKLabelNode = SKLabelNode(fontNamed: "HelveticaNeue")
        label.text = text
        label.fontSize = 14.0
        label.fontColor = .gray
        label.zPosition = -999
        
        return label
    }
    
    private func drawGridLinesFor(axis: Axis, direction: Direction, dirtyRect: CGRect) {
    
        var currentPoint: CGFloat = 0.0
        var keepGoing = true
        var iteration = 0
        
        self.minorGridColor.set()
        
        while (keepGoing) {
            let x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat
            switch axis {
            case .x:
                x1 = dirtyRect.midX + (CGFloat(iteration) * self.gridStrideSize)
                y1 = 0
                x2 = x1
                y2 = dirtyRect.maxY
                currentPoint += self.gridStrideSize
                break
                
            case .y:
                x1 = 0
                y1 = dirtyRect.midY + (CGFloat(iteration) * self.gridStrideSize)
                x2 = dirtyRect.maxX
                y2 = y1
                currentPoint += self.gridStrideSize
                break
            }
            
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: x1, y: y1))
            bezierPath.addLine(to: CGPoint(x: x2, y: y2))
            
            bezierPath.lineWidth = self.gridLineWidth
            bezierPath.stroke()
            
            if direction == .back {
                iteration -= 1
            } else {
                iteration += 1
            }
            
            switch axis {
            case .x:
                keepGoing = currentPoint <= (dirtyRect.maxX)
                break
                
            case .y:
                keepGoing = currentPoint <= (dirtyRect.maxY)
                break
            }
        }
    }
    
    private enum Axis {
        case x
        case y
    }
    
    private enum Direction {
        case back
        case forward
    }
}
