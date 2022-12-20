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
    private let limitIncreaser: Int = 20
    private var limit: Int = 20
    private var result: [CategoryModel.ResultCategory] = []
    
    private let categoryName: String
    init(categoryName: String) {
        self.categoryName = categoryName
        super.init(nibName: nil, bundle: nil)
        setupUI()
        loadData(isInitial: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        gradientContentView.addSubview(collectionView)
        modalPresentationStyle = .fullScreen
        setupNavigationBar(with: categoryName)
        
        collectionView.backgroundColor = .clear
        collectionView.register(FullContentViewImageCollectionViewCell.self, forCellWithReuseIdentifier: FullContentViewImageCollectionViewCell.identifier)
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
    
    private func loadData(isInitial: Bool) {
        if isInitial {
            limit = limitIncreaser
        } else {
            limit += limitIncreaser
        }
        
        FirebaseManager.shared.firestore.collection("Category").document(categoryName).getDocument() { [weak self] snapshot, error in
            guard let self = self else { return }
            
            guard let snapshotData = snapshot?.data() else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotData) else { return }
            
            do {
                let model = try JSONDecoder().decode(CategoryModel.self, from: data)
                print(model)
                
                DispatchQueue.main.async {
                    self.result = model.result ?? []
                    self.collectionView.reloadData()
                }
            } catch let error {
                print(error)
            }
        }
    }
}

extension CategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        result.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullContentViewImageCollectionViewCell.identifier, for: indexPath) as! FullContentViewImageCollectionViewCell
        if indexPath.row < result.count {
            let photo = result[indexPath.row].photo
            if let url = URL(string: photo) {
                cell.setImage(url: url)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width - (Layout.leading * 2) - minimumInteritemSpacingForSection) / numberOfCollectionViewColumns, height: view.bounds.height / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("TAPPED IN collectionView CategoryVC")
        if let cell = collectionView.cellForItem(at: indexPath) as? FullContentViewImageCollectionViewCell {
            if let image = cell.recommendationImageView.image {
                let vc = FullSizeWallpaperVC(image: image)
                self.present(vc, animated: true)
            }
        }
    }
}

struct CategoryModel: Codable {
    let result: [ResultCategory]?
    
    struct ResultCategory: Codable {
        let photo: String
        let prompt, negative_prompt: String?
    }
}
