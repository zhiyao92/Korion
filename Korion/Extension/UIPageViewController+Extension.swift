import UIKit

extension UIPageViewController {

    func isScrollingEnabled(_ isEnabled: Bool) {
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = isEnabled
            }
        }
    }
}
