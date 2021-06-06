//
//  DetailViewController.swift
//  WKWebViewDemo
//
//  Created by KuanWei on 2020/7/11.
//  Copyright © 2020 kuanwei. All rights reserved.
//

import UIKit
import WebKit

// https://medium.com/dev-genius/how-to-get-cookies-from-wkwebview-and-uiwebview-in-swift-46e1a072a606
class DetailViewController: UIViewController, UIWebViewDelegate {
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences = preferences
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return webView
    }()

    var oldWebView: UIWebView!

    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let removeCookieButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeCookie))
        navigationItem.rightBarButtonItem = removeCookieButton

        if #available(iOS 11, *) {
            webView.uiDelegate = self
            view = webView
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: [.new, .old], context: nil)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)

        } else {
            oldWebView = UIWebView()
            oldWebView.frame =  CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            oldWebView.delegate = self
            view = oldWebView
        }

        let myURL = URL(string: "https://today.line.me/id")
        let myRequest = URLRequest(url: myURL!)

        if #available(iOS 11, *) {
            webView.load(myRequest)
            webView.navigationDelegate = self
        } else {
            oldWebView.loadRequest(myRequest)
            oldWebView.delegate = self
        }

        addCookieUsingJavascript()
        addCookieUsingCookieStore()
        webView.reload()
    }

    @objc func removeCookie() {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if cookie.name == "javaScriptName" {
                    print("find cookie")
                    self.webView.configuration.websiteDataStore.httpCookieStore.delete(cookie)
                } else {
                    print("\(cookie.name) is set to \(cookie.value)")
                }
            }
        }
//        guard let cookie = HTTPCookie.cookie(name: "javaScriptName", value: "javaScriptValue", domain: "today.line.me", path: "/") else {
//            return
//        }
//        webView.removeCookie(cookie)
        webView.reload()
    }

    func addCookieUsingJavascript() {
        guard let cookie = HTTPCookie.cookie(name: "javaScriptName", value: "javaScriptValue", domain: "today.line.me", path: "/") else {
            return
        }

        let script = WKWebView.addCookieScript(cookie)
        webView.configuration.userContentController.addUserScript(script)
    }

    func addCookieUsingCookieStore() {
        guard let cookie = HTTPCookie.cookie(name: "CookieStoreName", value: "CookieStoreValue", domain: "today.line.me", path: "/") else {
            return
        }
        webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 11, *) {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.httpCookieStore.getAllCookies({ (cookies) in
                print(cookies.count)
                print(cookies)
            })
        } else {
            guard let cookies = HTTPCookieStorage.shared.cookies else {
                return
            }
            print(cookies)
        }

        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if cookie.name == "javaScriptName" {
                    print("find cookie")
                    self.webView.configuration.websiteDataStore.httpCookieStore.delete(cookie)
                } else {
                    print("\(cookie.name) is set to \(cookie.value)")
                }
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
}

extension DetailViewController: WKUIDelegate {
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

extension DetailViewController: WKNavigationDelegate {
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
