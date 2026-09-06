import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.text = "CarPlay Browser is running.\nPlease connect to CarPlay to view YouTube."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.frame = view.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(label)
        
        view.backgroundColor = .systemBackground
    }
}
