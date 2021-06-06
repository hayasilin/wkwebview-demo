//
//  MainTabBarController.swift
//  WKWebViewDemo
//
//  Created by KuanWei on 2020/8/5.
//  Copyright © 2020 kuanwei. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let glnPage = UINavigationController(rootViewController: ViewController())
        glnPage.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 0)
        let ecacPage = UINavigationController(rootViewController: DetailViewController())
        ecacPage.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 1)

        viewControllers = [glnPage, ecacPage]
        selectedViewController = glnPage

        tabBar.barTintColor = .white
        tabBar.tintColor = .black
        tabBar.shadowImage = UIImage()
        tabBar.isTranslucent = false
    }
}
