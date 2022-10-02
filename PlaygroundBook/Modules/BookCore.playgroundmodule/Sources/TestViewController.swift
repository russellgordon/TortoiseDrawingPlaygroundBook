import UIKit
import PlaygroundSupport

public class TestViewController: UIViewController {
    
    var responseLabel: UILabel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        responseLabel = UILabel()
        responseLabel.textAlignment = .center
        responseLabel.translatesAutoresizingMaskIntoConstraints = true
        responseLabel.font = UIFont.boldSystemFont(ofSize: 30)
        responseLabel.adjustsFontSizeToFitWidth = true
        responseLabel.numberOfLines = 0
        view.addSubview(responseLabel)
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        responseLabel.text = "Appeared"
        setBgColor(color: .red)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        responseLabel.bounds = view.bounds
        responseLabel.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        
    }
    
    public func setBgColor(color: UIColor) {
        view.backgroundColor = color
    }
    
    /// Immediately appends new text to the label.
    public func reply(_ message: String) {
        let currentText = self.responseLabel.text ?? ""
        self.responseLabel.text = "\(currentText)\n\(message)"
    }
    
}

extension TestViewController: PlaygroundLiveViewMessageHandler {
    
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
            reply("You sent: \(text)")
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
