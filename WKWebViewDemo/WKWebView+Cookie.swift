//
//  WKWebView+Cookie.swift
//  WKWebViewDemo
//
//  Created by KuanWei on 2020/7/20.
//  Copyright © 2020 kuanwei. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    func removeScript(_ scriptToRemove: WKUserScript) {
        let remainingScripts = configuration.userContentController.userScripts.filter {
            return $0 !== scriptToRemove
        }

        configuration.userContentController.removeAllUserScripts()
        for script in remainingScripts {
            configuration.userContentController.addUserScript(script)
        }
    }

    func removeCookie(_ cookie: HTTPCookie) {
        let scriptString = "document.cookie = '\(cookie.name)=; domain=\(cookie.domain); path=\(cookie.path)';"
        evaluateJavaScript(scriptString, completionHandler: nil)
    }

    static func addCookieScript(_ cookie: HTTPCookie) -> WKUserScript {
        let scriptString = "document.cookie = '\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path)';"
        return WKUserScript(source: scriptString, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    }
}
