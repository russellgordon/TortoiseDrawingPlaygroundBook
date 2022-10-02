import UIKit

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

}
