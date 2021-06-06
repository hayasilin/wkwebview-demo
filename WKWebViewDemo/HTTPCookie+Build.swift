//
//  HTTPCookie+Build.swift
//  WKWebViewDemo
//
//  Created by KuanWei on 2020/7/20.
//  Copyright © 2020 kuanwei. All rights reserved.
//

import Foundation

extension HTTPCookie {
    static func cookie(name: String, value: String, domain: String, path: String) -> HTTPCookie? {
        var properties = [HTTPCookiePropertyKey: Any]()
        properties[.name] = name
        properties[.value] = value
        properties[.domain] = domain
        properties[.path] = path
        return HTTPCookie(properties: properties)
    }
}
