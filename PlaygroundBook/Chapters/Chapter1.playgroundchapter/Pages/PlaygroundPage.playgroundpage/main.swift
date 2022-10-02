//#-hidden-code

import BookCore
import PlaygroundSupport
import SpriteKit

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
 The code below creates a turtle that will draw shapes for you.
 */
var turtle = Tortoise()
/*:
 Add code below to make the turtle draw things for you.
 
 Begin by typing:
 
 `turtle.`
 
 ... to see what the turtle can do.
 
 Press **Command-R** to run your code.
 
 Press **Shift-Command-R** to step through your code.
 */
//#-editable-code
// This draws a circle starting at the origin
turtle.arc(radius: 100, angle: 360)

// This draws a line moving to the right
turtle.forward(distance: 100)

// NOTE: You should remove all of this code,
//       and replace it with your own.
//       You will learn a lot by trying
//       things out!
//#-end-editable-code
