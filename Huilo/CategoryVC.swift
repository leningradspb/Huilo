//
//  CategoryVC.swift
//  Huilo
//
//  Created by Eduard Kanevskii on 18.12.2022.
//

import UIKit

class CategoryVC: GradientVC {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let minimumInteritemSpacingForSection: CGFloat = 12
    private let numberOfCollectionViewColumns: CGFloat = 2
    
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
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = .clear
        collectionView.register(GeneratorFiltersCollectionViewCell.self, forCellWithReuseIdentifier: GeneratorFiltersCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 20, left: Layout.leading, bottom: 20, right: Layout.leading)
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumLineSpacing = 10
        }
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension CategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GeneratorFiltersCollectionViewCell.identifier, for: indexPath) as! GeneratorFiltersCollectionViewCell
//        if indexPath.row < filters.count {
//            let filter = filters[indexPath.row]
//            cell.updateWith(generatorFilterModel: filter, isSelected: userSelectedFilters.contains(where: {$0.name == filter.name}))
//        }
//
//        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width - (Layout.leading * 2) - minimumInteritemSpacingForSection) / numberOfCollectionViewColumns, height: view.bounds.height / 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.row < filters.count {
//            let filter = filters[indexPath.row]
//            if userSelectedFilters.contains(where: { $0.name == filter.name }) {
//                userSelectedFilters.removeAll(where: { $0.name == filter.name })
//            } else {
//                userSelectedFilters.append(filter)
//            }
//            collectionView.reloadItems(at: [indexPath])
//        }
        
    }
}
