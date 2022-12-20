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
        
        checkForceUpdate()
    }
    
    private func checkForceUpdate() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let appVersionDouble = Double(appVersion) else {
            setupTabBar()
            return
        }
        
        FirebaseManager.shared.firestore.collection("ForceUpdate").document("ForceUpdate").getDocument { [weak self] snapshot, error in
            guard let self = self else {
                self?.setupTabBar()
                return
            }
            guard let snapshotData = snapshot?.data() else {
                self.setupTabBar()
                return
            }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else {
                self.setupTabBar()
                return
            }
            
            do {
                let model = try JSONDecoder().decode(ForceUpdateModel.self, from: data)
                if appVersionDouble < model.supportedVersion {
                    DispatchQueue.main.async {
                        let modal = ErrorModal(errorText: "force update required🤖 please update the app", isForceUpdate: true)
                        self.window.addSubview(modal)
                    }
                } else {
                    self.setupTabBar()
                }
            } catch let error {
                print(error)
                self.setupTabBar()
            }
        }
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


struct ForceUpdateModel: Codable {
    let supportedVersion: Double
}
