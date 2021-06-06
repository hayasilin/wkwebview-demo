//
//  WebViewHelper.swift
//  WKWebViewDemo
//
//  Created by KuanWei on 2020/7/5.
//  Copyright © 2020 kuanwei. All rights reserved.
//

import Foundation
import WebKit

class WebViewHelper {
    private var tempWebView = WKWebView(frame: .zero)
    let trailingUserAgent = "hahaha/3.9"

    func saveCustomUserAgent(completion: @escaping (Bool) -> Void) {
        tempWebView.evaluateJavaScript("navigator.userAgent") { (result, error) in
            guard let userAgent = result as? String else {
                print("Error getting system user agent: \(String(describing: error))")
                completion(false)
                return
            }
            let newAgentString = userAgent + " " + self.trailingUserAgent
//            UserDefaultsManager.save(string: newAgentString, forKey: .lineTodayUserAgent)
            print("Saved custom user agent: \(newAgentString)")
            completion(true)
        }
    }
}
