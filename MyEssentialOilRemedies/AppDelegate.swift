//
//  AppDelegate.swift
//  MyEssentialOilRemedies
//
//  Created by burnsoft on 6/9/16.
//  Copyright © 2016 burnsoft. All rights reserved.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Selected tab color, unselected tab color, and the normal tab title color.
        UITabBar.appearance().tintColor = .systemGray6
        UITabBar.appearance().unselectedItemTintColor = .black
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        return true
    }

    /// Apps built with the iOS 27 SDK must use the scene-based life cycle, so every window scene
    /// uses SceneDelegate and loads the main storyboard.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        configuration.storyboard = UIStoryboard(name: "iphone", bundle: nil)
        return configuration
    }
}
