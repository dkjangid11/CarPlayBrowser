import CarPlay
import UIKit
import WebKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, CPMapTemplateDelegate {
    
    var window: UIWindow?
    var interfaceController: CPInterfaceController?
    var mapTemplate: CPMapTemplate?
    var webView: WKWebView?
    
    // This is called when the CarPlay display connects
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController, to window: CPWindow) {
        
        self.interfaceController = interfaceController
        self.window = window
        
        // 1. Setup the dummy Map Template
        // We MUST use a map template to satisfy the CarPlay navigation entitlement.
        let mapTemplate = CPMapTemplate()
        mapTemplate.mapDelegate = self
        self.mapTemplate = mapTemplate
        
        // 2. Setup the Web View
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        if #available(iOS 14.0, *) {
            webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        let webView = WKWebView(frame: window.bounds, configuration: webConfiguration)
        self.webView = webView
        
        // 3. Setup the custom UIViewController to hold our WebView
        let rootViewController = UIViewController()
        rootViewController.view.backgroundColor = .black
        
        rootViewController.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: rootViewController.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: rootViewController.view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: rootViewController.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: rootViewController.view.trailingAnchor)
        ])
        
        // 4. THE LOOPHOLE: Assign our custom view controller directly to the CarPlay window
        window.rootViewController = rootViewController
        window.isUserInteractionEnabled = true
        window.makeKeyAndVisible()
        
        // Push the map template so CarPlay doesn't complain about a missing template
        interfaceController.setRootTemplate(mapTemplate, animated: false, completion: nil)
        
        // 5. Load YouTube
        if let url = URL(string: "https://www.youtube.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        // 6. Setup Navigation Buttons on the map template
        setupNavigationButtons()
    }
    
    private func setupNavigationButtons() {
        let backButton = CPMapButton { [weak self] _ in
            if self?.webView?.canGoBack == true {
                self?.webView?.goBack()
            }
        }
        backButton.image = UIImage(systemName: "chevron.left")
        
        let forwardButton = CPMapButton { [weak self] _ in
            if self?.webView?.canGoForward == true {
                self?.webView?.goForward()
            }
        }
        forwardButton.image = UIImage(systemName: "chevron.right")
        
        let reloadButton = CPMapButton { [weak self] _ in
            self?.webView?.reload()
        }
        reloadButton.image = UIImage(systemName: "arrow.clockwise")
        
        mapTemplate?.mapButtons = [backButton, forwardButton, reloadButton]
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController,
                                  from window: CPWindow) {
        self.interfaceController = nil
        self.window = nil
        self.webView = nil
    }
}
