//
//  AppDelegate.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor.clear
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .dark)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.white

        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont.futura(withSize: 14)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.font: UIFont.futura(withSize: 14)], for: .selected)
        
//        UINavigationBar.appearance().backgroundColor = .red
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.futura(withSize: 30)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.futura(withSize: 30)]
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        
        let scrollingAppearance = UINavigationBarAppearance()
        scrollingAppearance.configureWithTransparentBackground()
        scrollingAppearance.backgroundColor = .clear
        scrollingAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.futura(withSize: 40)]
        scrollingAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.futura(withSize: 30)]

        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = scrollingAppearance
        UINavigationBar.appearance().compactAppearance = scrollingAppearance
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

