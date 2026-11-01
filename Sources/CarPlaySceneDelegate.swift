import CarPlay
import UIKit
import WebKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, CPMapTemplateDelegate, WKNavigationDelegate {

    var window: UIWindow?
    var interfaceController: CPInterfaceController?
    var mapTemplate: CPMapTemplate?
    var webView: WKWebView?

    // MARK: - CarPlay connection

    // Called when the CarPlay display connects.
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController, to window: CPWindow) {

        self.interfaceController = interfaceController
        self.window = window

        // 1. Map template: required to satisfy the CarPlay navigation entitlement.
        let mapTemplate = CPMapTemplate()
        mapTemplate.mapDelegate = self
        self.mapTemplate = mapTemplate

        // 2. Web view
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: window.bounds, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        self.webView = webView

        // 3. View controller that hosts the web view
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

        // 4. Assign the custom view controller directly to the CarPlay window.
        window.rootViewController = rootViewController
        window.isUserInteractionEnabled = true
        window.makeKeyAndVisible()

        // The map template keeps CarPlay happy and carries the navigation buttons.
        interfaceController.setRootTemplate(mapTemplate, animated: false, completion: nil)

        // 5. Resume the last page, or open the home page.
        webView.load(URLRequest(url: BrowserSettings.lastURL ?? BrowserSettings.homeURL))

        // 6. Navigation buttons
        setupNavigationButtons()
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController,
                                  from window: CPWindow) {
        webView?.stopLoading()
        webView?.navigationDelegate = nil
        window.rootViewController = nil

        self.interfaceController = nil
        self.mapTemplate = nil
        self.window = nil
        self.webView = nil
    }

    // MARK: - Map buttons

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
            self?.reloadOrRetry()
        }
        reloadButton.image = UIImage(systemName: "arrow.clockwise")

        let homeButton = CPMapButton { [weak self] _ in
            self?.webView?.load(URLRequest(url: BrowserSettings.homeURL))
        }
        homeButton.image = UIImage(systemName: "house")

        mapTemplate?.mapButtons = [backButton, forwardButton, reloadButton, homeButton]
    }

    /// Reloads the current page; if an error page is showing, retries the last real page instead.
    private func reloadOrRetry() {
        guard let webView = webView else { return }
        if let url = webView.url, url.scheme == "http" || url.scheme == "https" {
            webView.reload()
        } else {
            webView.load(URLRequest(url: BrowserSettings.lastURL ?? BrowserSettings.homeURL))
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url, url.scheme == "http" || url.scheme == "https" {
            BrowserSettings.lastURL = url
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showError(error)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError(error)
    }

    private func showError(_ error: Error) {
        let nsError = error as NSError
        // Cancelled loads (e.g. the user tapped a link mid-load) are not errors worth showing.
        guard nsError.code != NSURLErrorCancelled else { return }

        let message = nsError.localizedDescription
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        let html = """
        <html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head>
        <body style="background:#000;color:#fff;font-family:-apple-system;text-align:center;padding-top:20vh">
        <h2>Couldn't load the page</h2>
        <p>\(message)</p>
        <p>Tap reload to try again.</p>
        </body></html>
        """
        webView?.loadHTMLString(html, baseURL: nil)
    }
}
