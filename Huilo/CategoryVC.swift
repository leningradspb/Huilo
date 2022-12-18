//
//  CategoryVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 18.12.2022.
//

import UIKit

class CategoryVC: GradientVC {
    
    private let categoryName: String
    init(categoryName: String) {
        self.categoryName = categoryName
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        modalPresentationStyle = .fullScreen
        setupNavigationBar(with: "category")
    }
}
