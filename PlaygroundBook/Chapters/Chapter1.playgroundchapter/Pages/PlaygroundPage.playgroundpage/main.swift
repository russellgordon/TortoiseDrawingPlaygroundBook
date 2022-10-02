//#-hidden-code

import BookCore
import PlaygroundSupport
import SpriteKit

//#-end-hidden-code
var turtle = Tortoise()
//#-hidden-code
// Reset the drawing
let page = PlaygroundPage.current
if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
    proxy.send(.string("Turtle asked to: reset drawing."))
}
//#-end-hidden-code
/*:
 
 Add code below to make the turtle draw things for you.
 
 Begin by typing:
 
 `turtle.`
 
 
 ... to see what the turtle can do for you.
 */
//#-editable-code
// For example, this draws a circle starting at the origin
// NOTE: You can delete this code and replace it with your own
turtle.arc(radius: 100, angle: 360)

//#-end-editable-code
