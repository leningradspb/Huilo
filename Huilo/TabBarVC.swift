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
        let flame = UIImage(systemName: "flame", withConfiguration: iconConfig)
        let flameSelected = UIImage(systemName: "flame.fill", withConfiguration: iconConfig)
        
        mainVC.tabBarItem.title = "main"
        mainVC.tabBarItem.image = flame
        mainVC.tabBarItem.selectedImage = flameSelected
        mainVC.tabBarItem.tag = 0
        
        let generatorNC = UINavigationController()
        let generatorVC = GeneratorVC()
        generatorNC.viewControllers = [generatorVC]
        let generate = UIImage(systemName: "paintbrush.pointed", withConfiguration: iconConfig)
        let generatSelected = UIImage(systemName: "paintbrush.pointed.fill", withConfiguration: iconConfig)
        generatorVC.tabBarItem.title = "ai generator"
        generatorVC.tabBarItem.image = generate
        generatorVC.tabBarItem.selectedImage = generatSelected
        generatorVC.tabBarItem.tag = 1
        
        tabBarList = [mainNC, generatorNC]
        viewControllers = tabBarList
    }
}
