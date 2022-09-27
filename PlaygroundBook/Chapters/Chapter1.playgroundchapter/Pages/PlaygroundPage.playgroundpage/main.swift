//#-hidden-code

import PlaygroundSupport
import SpriteKit
import BookCore

func addShape(drawnBy: Tortoise){
    let view = GridPaperView()
    view.add(turtle)
    PlaygroundPage.current.liveView = view
}
//#-end-hidden-code

// Create a turtle to draw things for you
var turtle = Tortoise()

//#-editable-code

// Add code below to make the turtle draw
// Begin with:
//
// turtle.
//
// ... and see what the turtle can do for you.

//#-end-editable-code

// Add the shape drawn by the turtle to the sketch
addShape(drawnBy: turtle)

