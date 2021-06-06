//
//  ViewController.swift
//  WKWebViewDemo
//
//  Created by kuanwei on 2020/4/10.
//  Copyright © 2020 kuanwei. All rights reserved.
//

import UIKit
import WebKit
import AdSupport
//import AppTrackingTransparency

// https://www.jianshu.com/p/f75feed39672
// https://www.fabrizioduroni.it/2019/08/03/html-javascript-to-native-communication-ios.html
class ViewController: UIViewController {
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let preferences = WKPreferences()
        webConfiguration.preferences = preferences

        let userController = WKUserContentController()
        userController.add(self, name: "observer")
        webConfiguration.userContentController = userController

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(navigationToDetailPage))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(goBack))

        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .white
        view = webView
        
        //        let userAgentValue = "Chrome/56.0.0.0 Mobile"
        //        webView.customUserAgent = userAgentValue

        // First way
        let url = URL(string:"https://today.line.me/tw")!
        let myRequest = URLRequest(url: url)
        webView.load(myRequest)

        // Second way
        let htmlString = "<html><head><h1>hello world</h1><h2>this is h2</h2></head></html>"
        let htmlData = htmlString.data(using: .utf8)!
        webView.load(htmlData, mimeType: "text/html", characterEncodingName: "UTF-8", baseURL: URL(string: "https://www.apple.com")!)

        // Third way
        let fileUrl = URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html")!)
        let data = try? Data(contentsOf: fileUrl, options: Data.ReadingOptions.mappedIfSafe.union(.uncached))
        webView.load(data!, mimeType: "text/html", characterEncodingName: "UTF-8", baseURL: URL(string: "https://www.apple.com")!)

        self.navigationController?.navigationBar.barTintColor = .white
//        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 19, weight: .heavy)]
//        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 10)]
//        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(-10, for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        if #available(iOS 13.0, *) {
//            let appearance = UINavigationBarAppearance()
//            appearance.shadowColor = .white
//            navigationController?.navigationBar.standardAppearance = appearance

        } else {

        }

//        if let result = identifierForAdvertising() {
//            print(result)
//        } else {
//            print("no idfa")
//        }
    }

//    func identifierForAdvertising() -> String? {
//        if #available(iOS 14, *) {
//            var result = ATTrackingManager.trackingAuthorizationStatus
//            print(result)
//            var uuid = ""
//            ATTrackingManager.requestTrackingAuthorization { (status) in
//                print(status)
//                switch status {
//                case .authorized:
//                    print("authorized")
//                    uuid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//                case .denied:
//                    print("denied")
//                case .notDetermined:
//                    print("notDetermined")
//                case .restricted:
//                    print("restricted")
//                }
//            }
//            return uuid
//        } else {
//            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
//                return nil
//            }
//            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
//        }
//    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: [.new, .old], context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
    }

    @objc func navigationToDetailPage(sender: UIBarButtonItem) {
        let detailPage = DetailViewController()
        navigationController?.pushViewController(detailPage, animated: true)
    }

    @objc func goBack(sender: UIBarButtonItem) {
        webView.goBack()
    }

    private func showUser(email: String, name: String) {
        let userDescription = "\(email) \(name)"
        let alertController = UIAlertController(title: "User", message: userDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)

        webView.evaluateJavaScript("document.getElementsByClassName('button')[0].innerText") { (result, error) in
            print("finish")
            if error == nil {
                print(result!)
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            let progress = Int(webView.estimatedProgress * 100)
            print("progress = \(progress)")
        } else if keyPath == #keyPath(WKWebView.url) && change?[NSKeyValueChangeKey.newKey] is URL {
            let newUrl = change?[NSKeyValueChangeKey.newKey] as? URL
            print("new url = \(newUrl!.absoluteURL)")
        } else if keyPath == #keyPath(WKWebView.title) {
            print("title = \(String(describing: webView.title))")
            navigationItem.title = webView.title
        }
    }

    func removeWKCacheWithUrl(urlString: String) {
        guard urlString.isEmpty == false else { return }

        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach {
                if urlString.contains($0.displayName) {
                    dataStore.removeData(ofTypes: $0.dataTypes, for: [$0], completionHandler: {})
                }
            }
        }
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(#function)
        if let data = message.body as? [String : String], let name = data["name"], let email = data["email"] {
            showUser(email: email, name: name)
        }
    }
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {

        completionHandler()
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {

        completionHandler(true)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {

        completionHandler("text")
    }
}

extension ViewController: WKNavigationDelegate {
    // MARK: - Initiating the navigation
    // Called when the web view begins to receive web content.
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit navigation")
    }

    // Called when web content begins to load in a web view.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation navigation")
    }

    // MARK: - Responding to server actions
    // Called when a web view receives a server redirect.
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }

    // MARK: - Authenitcation challenges
    // Called wehn the web view needs to respond to an authentication challenges.
//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("URLAuthenticationChallenge")
//    }

    // MARK: - Reacting to errors
    // Called when an error occurs during navigation.
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail navigation")
    }

    // Called when an error occurs while the web view is loading content.
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation navigation")
    }

    // MARK: - Tracking load progress
    // Called when the navigation is complete.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish navigation")
    }

    // Called when the web view's web content process is terminated
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("webViewWebContentProcessDidTerminate")
    }

    // MARK: - Permitting navigation
    // Decides whether to allow or cancel a navigation.
    // 根據url來判斷web view是否跳轉到外部連結
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("decidePolicyFor navigationAction")
        decisionHandler(.allow)
    }

    // 根據server返回判斷是否可以跳轉外部連結
    // Decides whether to allow or cancel a navigation after its response is known
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("decidePolicyFor navigationResponse")

        decisionHandler(.allow)
    }
}
