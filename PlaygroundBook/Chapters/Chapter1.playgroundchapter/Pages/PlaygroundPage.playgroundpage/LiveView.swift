//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//

import UIKit
import BookCore
import PlaygroundSupport

let page = PlaygroundPage.current
page.liveView = LiveCanvasViewController()

//// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport.
//PlaygroundPage.current.liveView = instantiateLiveView()
//
//class MessageHandler: PlaygroundRemoteLiveViewProxyDelegate {
//
//    func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy,
//                             received message: PlaygroundValue) {
//        print("Received a message from the always-on live view", message)
//    }
//
//    func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
//
//    }
//}
//
////guard let remoteView = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else {
////    fatalError("Always-on live view not configured in this page's LiveView.swift.")
////}
////
//
//let remoteView = PlaygroundPage.current.liveView as! PlaygroundRemoteLiveViewProxy
//
//remoteView.delegate = MessageHandler()
