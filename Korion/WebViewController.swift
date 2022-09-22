import UIKit
import WebKit

class WebViewController: UIViewController {
    
    private var webView: WKWebView!
        
    var setPageControlScrollingEnabled: ((Bool) -> Void)?
    var setBackButtonEnabled: ((Bool) -> Void)?
    var setForwardButtonEnabled: ((Bool) -> Void)?
    var moveToHomeScreen: (() -> Void)?
    
    // Code improvement: Should add to ViewModel
    private let localStorageProvider: LocalStorageProvider = LocalStorageProvider(localStorage: UserDefaults.standard)
    
    private var urlHistory: [String] = []
    private var currentIndex = 0
    private var isAtHomeScreen = false
    
    private let urlOne = "https://stil.kurir.rs/moda/157971/ovo-su-najstilizovanije-zene-sveta-koja-je-po-vama-br-1-anketa"
//    private let urlOne = "https://github1s.com/lynoapp/"
//    private let urlOne = "https://google.com/"

    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        
        loadUrl(localStorageProvider.get(.urlLastVisited) as? String ?? urlOne)
        urlHistory = localStorageProvider.get(.urlHistory) as? [String] ?? []
    }
        
    private func configureWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = .video
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        webView.setShadowWithColor(color: .black, opacity: 0.4, offset: CGSize(width: 0.0, height: 1.0), radius: 3, viewCornerRadius: 0)
        view = webView
    }
    
    func handleWebViewBack() {
        if let index = urlHistory.firstIndex(where: { $0 == webView.url?.absoluteString }), index > 0 {
            let url = urlHistory[index - 1]
            loadUrl(url)
            setForwardButtonEnabled?(true)
        } else {
            setPageControlScrollingEnabled?(true)
            setBackButtonEnabled?(false)
            moveToHomeScreen?()
            isAtHomeScreen = true
        }
    }
    
    func handleWebViewForward() {
        let urlHistoryCount = urlHistory.count - 1
        if let index = urlHistory.firstIndex(where: { $0 == webView.url?.absoluteString }), index < urlHistoryCount {
            if isAtHomeScreen {
                loadUrl(urlOne)
                isAtHomeScreen = false
            } else {
                let incrementalCount = index + 1
                let url = urlHistory[incrementalCount]
                loadUrl(url)
                setBackButtonEnabled?(true)
                setForwardButtonEnabled?(incrementalCount != urlHistoryCount)
            }
        } else {
            loadUrl(urlOne)
        }
    }
    
    func loadUrl(_ url: String?) {
        guard let website = url,
              let url = URL(string: website)
        else { return }

        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
    
    private func setWebViewHidden(_ isHidden: Bool) {
        webView.isHidden = isHidden
    }
    
    private func persistHistory() {
        localStorageProvider.set(urlHistory, key: .urlHistory)
        localStorageProvider.set(urlHistory[urlHistory.count - 1], key: .urlLastVisited)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        guard let url = webView.url?.absoluteString else { return }
        
        setPageControlScrollingEnabled?(url == urlOne)

        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url?.absoluteString else { return }

        if !urlHistory.contains(url) {
            urlHistory.append(url)
            persistHistory()
        }
    }
}
