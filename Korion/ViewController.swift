import UIKit

class ViewController: UIViewController {
    
    private lazy var homeScreen: HomeViewController = {
        let viewController = HomeViewController()
        viewController.pressLoadButton = { [weak self] in
            self?.moveToWebScreen(nil)
            self?.localStorageProvider.removeValue(at: .urlHistory)
            self?.localStorageProvider.removeValue(at: .urlLastVisited)
        }
        return viewController
    }()
    
    private lazy var webScreen: WebViewController = {
        let viewController = WebViewController()
        viewController.setPageControlScrollingEnabled = { [weak self] isEnabled in
            self?.setPageControlScrollEnabled(isEnabled)
        }
        viewController.setBackButtonEnabled = { [weak self] isEnabled in
            self?.setBackButtonEnabled(isEnabled)
        }
        viewController.setForwardButtonEnabled = { [weak self] isEnabled in
            self?.setForwardButtonEnabled(isEnabled)
        }
        viewController.moveToHomeScreen = { [weak self] in
            self?.moveToHomeScreen()
        }
        return viewController
    }()
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var backToolBarItem: UIBarButtonItem!
    @IBOutlet weak var forwardToolBarItem: UIBarButtonItem!
    
    private var pageController: UIPageViewController!
    private var contentViewControllers: [UIViewController] = []
    private let maximumCount = 1

    // Code improvement: Should add to ViewModel
    private let localStorageProvider: LocalStorageProvider = LocalStorageProvider(localStorage: UserDefaults.standard)

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageController()
        configureToolBar()
        checkLastOpenedSite()
        configureSwipeRecognizer()
    }
    
    private func configureSwipeRecognizer() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipe.direction = .right
        swipe.delegate = self
        webScreen.view.addGestureRecognizer(swipe)
    }
    
    @objc func handleSwipe(_ recognizer: UISwipeGestureRecognizer) {
        print("need to handle index")
    }
    
    private func configureToolBar() {
        self.pageController.view.addSubview(toolBar)
        self.setForwardButtonEnabled(false)
        self.setBackButtonEnabled(false)
    }
    
    private func configurePageController() {
        let optionsDict = [UIPageViewController.OptionsKey.interPageSpacing: 20]
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: optionsDict)
        pageController.dataSource = self
        pageController.delegate = self
        pageController.view.backgroundColor = .clear
        pageController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        addChild(self.pageController)
        view.addSubview(self.pageController.view)
        contentViewControllers = [homeScreen, webScreen]
        pageController.setViewControllers([contentViewControllers[0]], direction: .forward, animated: false, completion: nil)
        
        pageController.didMove(toParent: self)
        setPageControlScrollEnabled(false)
    }
    
    private func checkLastOpenedSite() {
        if let _ = localStorageProvider.get(.urlLastVisited) {
            moveToWebScreen(nil)
        }
    }
    
    private func moveToWebScreen(_ completion: (() -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            self?.pageController.setViewControllers([self?.contentViewControllers[1] ?? UIViewController()], direction: .forward, animated: true) { [weak self] _ in
                self?.setBackButtonEnabled(true)
                self?.setPageControlScrollEnabled(true)
            }
            self?.pageController?.didMove(toParent: self)
            completion?()
        }
    }
    
    private func moveToHomeScreen() {
        DispatchQueue.main.async { [weak self] in
            self?.pageController.setViewControllers([self?.contentViewControllers[0] ?? UIViewController()], direction: .reverse, animated: true, completion: nil)
            self?.pageController?.didMove(toParent: self)
        }
    }
    
    private func setPageControlScrollEnabled(_ isEnabled: Bool) {
        pageController.isScrollingEnabled(isEnabled)
    }
    
    @IBAction func pressBackButton(_ sender: UIBarButtonItem) {
        webScreen.handleWebViewBack()
    }

    @IBAction func pressForwardButton(_ sender: UIBarButtonItem) {
        moveToWebScreen { [weak self] in
            self?.webScreen.handleWebViewForward()
        }
    }
    
    private func setBackButtonEnabled(_ isEnabled: Bool) {
        backToolBarItem.isEnabled = isEnabled
        backToolBarItem.tintColor = isEnabled ? .systemBlue : .systemGray
    }
    
    private func setForwardButtonEnabled(_ isEnabled: Bool) {
        forwardToolBarItem.isEnabled = isEnabled
        forwardToolBarItem.tintColor = isEnabled ? .systemBlue : .systemGray
    }
}

extension ViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = contentViewControllers.firstIndex(of: viewController)!
        
        guard currentIndex > 0 else {
            return nil
        }

        return contentViewControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = contentViewControllers.firstIndex(of: viewController)!

        guard currentIndex < contentViewControllers.count - 1 else {
            return nil
        }
        
        return contentViewControllers[currentIndex + 1]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return maximumCount
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIScreenEdgePanGestureRecognizer
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
