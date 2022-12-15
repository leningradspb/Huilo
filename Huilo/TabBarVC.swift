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
        
        let mainNC = UINavigationController()
        let mainVC = MainVC()
        mainNC.viewControllers = [mainVC]
        let iconConfig = UIImage.SymbolConfiguration(scale: .large)
        let bubbleIcon = UIImage(systemName: "flame.fill", withConfiguration: iconConfig)
        
        mainVC.tabBarItem.title = "main"
        mainVC.tabBarItem.image = bubbleIcon
        mainVC.tabBarItem.tag = 0
        
        let generatorNC = UINavigationController()
        let generatorVC = GeneratorVC()
        generatorNC.viewControllers = [generatorVC]
        let generatorIcon = UIImage(systemName: "flame.fill", withConfiguration: iconConfig)
        generatorVC.tabBarItem.title = "ai genaretor"
        generatorVC.tabBarItem.image = generatorIcon
        generatorVC.tabBarItem.tag = 1
        
        tabBarList = [mainNC, generatorNC]
        viewControllers = tabBarList
    }
}
