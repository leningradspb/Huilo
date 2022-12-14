//
//  TabBarVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 14.12.2022.
//

import UIKit

class TabBarVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
    }
    
    private func setupTabBar() {
        var tabBarList: [UIViewController]!
        
        let searchNC = UINavigationController()
        let searchVC = SearchVC()
        searchNC.viewControllers = [searchVC]
        let iconConfig = UIImage.SymbolConfiguration(scale: .large)
        let bubbleIcon = UIImage(systemName: "flame.fill", withConfiguration: iconConfig)
        
        searchVC.tabBarItem.title = nil
        searchVC.tabBarItem.image = bubbleIcon
        searchVC.tabBarItem.tag = 0
        
        tabBarList = [searchNC]
        viewControllers = tabBarList
    }
}
