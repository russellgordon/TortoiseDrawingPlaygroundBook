//#-hidden-code

import BookCore
import PlaygroundSupport
import SpriteKit

//#-end-hidden-code
var turtle = Tortoise()
//#-hidden-code
// Start a new drawing
let page = PlaygroundPage.current
if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
    let action = PlaygroundValue.dictionary([
        "Command": .string("startNewDrawing")
    ])
    proxy.send(action)
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
