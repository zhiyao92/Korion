import UIKit

class HomeViewController: UIViewController {
    
    var pressLoadButton: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapLoadButton() {
        pressLoadButton?()
    }
}
