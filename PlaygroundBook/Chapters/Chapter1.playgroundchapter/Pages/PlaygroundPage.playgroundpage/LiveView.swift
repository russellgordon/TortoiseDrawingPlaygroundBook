//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//

import UIKit
import BookCore
import PlaygroundSupport

// Reference to current playground page
let page = PlaygroundPage.current

// Make the controller appear as the live view
page.liveView = LiveCanvasViewController()
